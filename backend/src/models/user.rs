use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct User {
    pub id: Uuid,
    pub unique_id: String,
    pub firebase_uid: String,
    pub phone_number: String,
    pub email: Option<String>,
    pub display_name: Option<String>,
    pub profile_image_url: Option<String>,
    pub biometric_enabled: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct RegisterRequest {
    pub firebase_uid: String,
    pub phone_number: String,
    pub email: Option<String>,
    pub display_name: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub firebase_uid: String,
}

#[derive(Debug, Deserialize)]
pub struct GoogleAuthRequest {
    pub firebase_uid: String,
    pub email: String,
    pub display_name: String,
    pub profile_image_url: String,
}

#[derive(Debug, Deserialize)]
pub struct UpdateProfileRequest {
    pub display_name: Option<String>,
    pub email: Option<String>,
    pub profile_image_url: Option<String>,
    pub biometric_enabled: Option<bool>,
}

#[derive(Debug, Serialize)]
pub struct AuthResponse {
    pub token: String,
    pub user: UserResponse,
}

#[derive(Debug, Serialize)]
pub struct UserResponse {
    pub id: String,
    pub unique_id: String,
    pub phone_number: String,
    pub email: Option<String>,
    pub display_name: Option<String>,
    pub profile_image_url: Option<String>,
    pub biometric_enabled: bool,
}

impl From<User> for UserResponse {
    fn from(user: User) -> Self {
        Self {
            id: user.id.to_string(),
            unique_id: user.unique_id,
            phone_number: user.phone_number,
            email: user.email,
            display_name: user.display_name,
            profile_image_url: user.profile_image_url,
            biometric_enabled: user.biometric_enabled,
        }
    }
}

pub fn generate_unique_id() -> String {
    let uuid = Uuid::new_v4();
    uuid.to_string().replace('-', "")[..16].to_uppercase()
}

pub fn gravatar_url(email: &str) -> String {
    let normalized = email.trim().to_lowercase();
    let digest = md5::compute(normalized.as_bytes());
    let hash = format!("{digest:x}");
    format!("https://www.gravatar.com/avatar/{hash}?d=identicon&s=200")
}
