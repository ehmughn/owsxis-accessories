# Owsxi Accessories - Shopify & Mobile Backend Integration

Project of Advanced Mobile Development

---

## 1. Backend Setup (`owsxi_backend`)

### Step 1: Install PHP Dependencies
Navigate to the backend directory and install dependencies:
```bash
cd owsxi_backend
composer install
```

### Step 2: Configure Environment Variables
Create your local `.env` file from `.env.example`:
```bash
cp .env.example .env
```

Open `.env` and configure your Shopify credentials:
```env
SHOPIFY_STORE_DOMAIN=owsxi.myshopify.com
SHOPIFY_CLIENT_ID=your_client_id_here
SHOPIFY_CLIENT_SECRET=your_client_secret_here
SHOPIFY_ACCESS_TOKEN=your_access_token_here
```

For the credentials, contact Eman (Me).

### Step 3: Start the Laravel API Server
Run the local dev server on port 8000:
```bash
php artisan serve --port=8000
```
The server will run at: `http://localhost:8000` or `http://127.0.0.1:8000`.

---

## 2. Mobile Application Setup (`owsxi_mobile`)

### Step 1: Install Flutter Packages
Navigate to the mobile directory and fetch packages:
```bash
cd owsxi_mobile
flutter pub get
```

### Step 2: Run the Mobile Application
Launch the Flutter app on your target platform (Android Emulator, iOS Simulator, Chrome, or Windows Desktop):
```bash
flutter run
```

---

## Network & Host Resolution

The mobile application (`owsxi_mobile`) includes automatic candidate host resolution:
- **Windows / Web / Desktop**: Connects to `http://127.0.0.1:8000/api` or `http://localhost:8000/api`.
- **Android Emulator**: Connects to `http://10.0.2.2:8000/api`.
