mod auth;
mod users;

use axum::{Router, routing::get};
use sqlx::PgPool;

use crate::config::Config;

pub fn create_router(pool: PgPool, config: &Config) -> Router {
    let jwt_secret = config.jwt_secret.clone();

    Router::new()
        .route("/health", get(health))
        .nest("/api/v1", auth::routes(pool.clone(), jwt_secret.clone()))
        .merge(users::routes(pool, jwt_secret))
}

async fn health() -> &'static str {
    "OK"
}
