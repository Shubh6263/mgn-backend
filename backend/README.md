# MedGlobal Network Backend

Rust API for MedGlobal Network.

## Local Development

```bash
cp .env.example .env
cargo run
```

The API listens on `PORT` and defaults to `8080`.

## Docker

```bash
docker build -t medglobalnetwork-backend .
docker run --rm -p 8080:8080 --env-file .env medglobalnetwork-backend
```

## Cloud Run Deployment

This backend is a good fit for a container host such as Google Cloud Run.

Build and deploy:

```bash
gcloud run deploy medglobalnetwork-backend \
  --source . \
  --region asia-south1 \
  --allow-unauthenticated \
  --set-env-vars JWT_SECRET=your-secret,RUST_LOG=info \
  --set-env-vars DATABASE_URL=your-postgres-url
```

Use the deployed Cloud Run URL as `API_BASE_URL` in the Flutter app.

