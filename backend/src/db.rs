use sqlx::{PgPool, postgres::PgPoolOptions};

pub async fn create_pool(database_url: &str) -> PgPool {
    PgPoolOptions::new()
        .max_connections(10)
        .connect(database_url)
        .await
        .expect("Failed to connect to PostgreSQL")
}

pub async fn run_migrations(pool: &PgPool) {
    let migration = include_str!("../migrations/001_create_users.sql");
    sqlx::raw_sql(migration)
        .execute(pool)
        .await
        .expect("Failed to run migrations");
}
