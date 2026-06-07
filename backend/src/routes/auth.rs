use axum::{
    Json, Router,
    extract::State,
    http::StatusCode,
    routing::post,
};
use jsonwebtoken::{EncodingKey, Header, encode};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use crate::models::{
    AuthResponse, GoogleAuthRequest, LoginRequest, RegisterRequest, User, generate_unique_id,
    gravatar_url,
};

#[derive(Clone)]
struct AuthState {
    pool: PgPool,
    jwt_secret: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct Claims {
    sub: String,
    unique_id: String,
    exp: usize,
}

pub fn routes(pool: PgPool, jwt_secret: String) -> Router {
    let state = AuthState { pool, jwt_secret };

    Router::new()
        .route("/auth/register", post(register))
        .route("/auth/login", post(login))
        .route("/auth/google", post(google_auth))
        .with_state(state)
}

async fn register(
    State(state): State<AuthState>,
    Json(body): Json<RegisterRequest>,
) -> Result<Json<AuthResponse>, (StatusCode, String)> {
    let existing: Option<User> = sqlx::query_as(
        "SELECT * FROM users WHERE firebase_uid = $1 OR phone_number = $2",
    )
    .bind(&body.firebase_uid)
    .bind(&body.phone_number)
    .fetch_optional(&state.pool)
    .await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    if existing.is_some() {
        return Err((
            StatusCode::CONFLICT,
            "User already exists".into(),
        ));
    }

    let unique_id = generate_unique_id();
    let profile_image_url = body
        .email
        .as_ref()
        .map(|e| gravatar_url(e));

    let user: User = sqlx::query_as(
        r#"
        INSERT INTO users (unique_id, firebase_uid, phone_number, email, display_name, profile_image_url)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING *
        "#,
    )
    .bind(&unique_id)
    .bind(&body.firebase_uid)
    .bind(&body.phone_number)
    .bind(&body.email)
    .bind(&body.display_name)
    .bind(&profile_image_url)
    .fetch_one(&state.pool)
    .await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let token = create_token(&user, &state.jwt_secret)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e))?;

    Ok(Json(AuthResponse {
        token,
        user: user.into(),
    }))
}

async fn login(
    State(state): State<AuthState>,
    Json(body): Json<LoginRequest>,
) -> Result<Json<AuthResponse>, (StatusCode, String)> {
    let user: User = sqlx::query_as("SELECT * FROM users WHERE firebase_uid = $1")
        .bind(&body.firebase_uid)
        .fetch_optional(&state.pool)
        .await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "User not found. Please register first.".into()))?;

    let token = create_token(&user, &state.jwt_secret)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e))?;

    Ok(Json(AuthResponse {
        token,
        user: user.into(),
    }))
}

async fn google_auth(
    State(state): State<AuthState>,
    Json(body): Json<GoogleAuthRequest>,
) -> Result<Json<AuthResponse>, (StatusCode, String)> {
    let existing: Option<User> = sqlx::query_as("SELECT * FROM users WHERE firebase_uid = $1")
        .bind(&body.firebase_uid)
        .fetch_optional(&state.pool)
        .await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let user = if let Some(u) = existing {
        u
    } else {
        let unique_id = generate_unique_id();
        let phone_placeholder = format!("google_{}", body.firebase_uid);

        sqlx::query_as(
            r#"
            INSERT INTO users (unique_id, firebase_uid, phone_number, email, display_name, profile_image_url)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING *
            "#,
        )
        .bind(&unique_id)
        .bind(&body.firebase_uid)
        .bind(&phone_placeholder)
        .bind(&body.email)
        .bind(&body.display_name)
        .bind(&body.profile_image_url)
        .fetch_one(&state.pool)
        .await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    };

    let token = create_token(&user, &state.jwt_secret)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e))?;

    Ok(Json(AuthResponse {
        token,
        user: user.into(),
    }))
}

fn create_token(user: &User, secret: &str) -> Result<String, String> {
    let exp = chrono::Utc::now()
        .checked_add_signed(chrono::Duration::days(30))
        .expect("valid timestamp")
        .timestamp() as usize;

    let claims = Claims {
        sub: user.id.to_string(),
        unique_id: user.unique_id.clone(),
        exp,
    };

    encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret.as_bytes()),
    )
    .map_err(|e| e.to_string())
}
