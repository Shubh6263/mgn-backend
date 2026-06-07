use axum::{
    Json, Router,
    extract::State,
    http::{HeaderMap, StatusCode},
    routing::get,
};
use jsonwebtoken::{DecodingKey, Validation, decode};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use uuid::Uuid;

use crate::models::{UpdateProfileRequest, User, UserResponse, gravatar_url};

#[derive(Clone)]
pub struct UserState {
    pub pool: PgPool,
    pub jwt_secret: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct Claims {
    sub: String,
    unique_id: String,
    exp: usize,
}

fn extract_user_id(headers: &HeaderMap, secret: &str) -> Result<Uuid, (StatusCode, String)> {
    let auth_header = headers
        .get("Authorization")
        .and_then(|v| v.to_str().ok())
        .ok_or((StatusCode::UNAUTHORIZED, "Missing Authorization header".into()))?;

    let token = auth_header
        .strip_prefix("Bearer ")
        .ok_or((StatusCode::UNAUTHORIZED, "Invalid Authorization format".into()))?;

    let token_data = decode::<Claims>(
        token,
        &DecodingKey::from_secret(secret.as_bytes()),
        &Validation::default(),
    )
    .map_err(|_| (StatusCode::UNAUTHORIZED, "Invalid token".into()))?;

    Uuid::parse_str(&token_data.claims.sub)
        .map_err(|_| (StatusCode::UNAUTHORIZED, "Invalid token subject".into()))
}

pub fn routes(pool: PgPool, jwt_secret: String) -> Router {
    Router::new()
        .route("/api/v1/users/me", get(get_me).put(update_me))
        .with_state(UserState { pool, jwt_secret })
}

async fn get_me(
    State(state): State<UserState>,
    headers: HeaderMap,
) -> Result<Json<UserResponse>, (StatusCode, String)> {
    let user_id = extract_user_id(&headers, &state.jwt_secret)?;
    let user: User = sqlx::query_as("SELECT * FROM users WHERE id = $1")
        .bind(user_id)
        .fetch_optional(&state.pool)
        .await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "User not found".into()))?;

    Ok(Json(user.into()))
}

async fn update_me(
    State(state): State<UserState>,
    headers: HeaderMap,
    Json(body): Json<UpdateProfileRequest>,
) -> Result<Json<UserResponse>, (StatusCode, String)> {
    let user_id = extract_user_id(&headers, &state.jwt_secret)?;

    let current: User = sqlx::query_as("SELECT * FROM users WHERE id = $1")
        .bind(user_id)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let display_name = body.display_name.or(current.display_name);
    let previous_email = current.email.clone();
    let email = body.email.or(current.email);
    let profile_image_url = if body.profile_image_url.is_some() {
        body.profile_image_url
    } else if email.as_ref() != previous_email.as_ref() {
        email.as_ref().map(|e| gravatar_url(e))
    } else {
        current.profile_image_url
    };
    let biometric_enabled = body.biometric_enabled.unwrap_or(current.biometric_enabled);

    let user: User = sqlx::query_as(
        r#"
        UPDATE users
        SET display_name = $1, email = $2, profile_image_url = $3, biometric_enabled = $4
        WHERE id = $5
        RETURNING *
        "#,
    )
    .bind(&display_name)
    .bind(&email)
    .bind(&profile_image_url)
    .bind(biometric_enabled)
    .bind(user_id)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    Ok(Json(user.into()))
}
