# Environment Variables Setup

This project uses environment variables to store sensitive API keys like the Mapbox access token.

## Setup Instructions

1. **Install dependencies** (if you haven't already):

   ```bash
   flutter pub get
   ```

2. **Create your `.env` file**:

   - Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Or manually create a `.env` file in the `app` directory

3. **Add your Mapbox access token**:

   - Open `.env` file
   - Replace `your_mapbox_access_token_here` with your actual Mapbox access token
   - Get your token from: https://account.mapbox.com/access-tokens/

4. **Example `.env` file**:
   ```
   MAPBOX_ACCESS_TOKEN=pk.eyJ1IjoidGVzdGVyczEyMyIsImEiOiJjbWkxN2RieDcxN21jMm5xMG5vdHJiYWFuIn0.0Ew0zviHigoWBjE_sn0Z-g
   MAPBOX_STYLE_ID=mapbox/streets-v11
   ```

## Important Notes

- ⚠️ **Never commit `.env` to version control** - it's already in `.gitignore`
- ✅ **Do commit `.env.example`** - it serves as a template for other developers
- The `.env` file is automatically loaded when the app starts (see `main.dart`)
- If the token is missing, the app will throw a clear error message

## Troubleshooting

If you see an error like:

```
MAPBOX_ACCESS_TOKEN not found in .env file
```

Make sure:

1. The `.env` file exists in the `app` directory (same level as `pubspec.yaml`)
2. The file contains `MAPBOX_ACCESS_TOKEN=your_token_here`
3. There are no extra spaces around the `=` sign
4. You've run `flutter pub get` to install `flutter_dotenv`
