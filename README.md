# Fixly AI - AI-Powered Service Marketplace

A production-ready Flutter mobile application that connects customers with home service providers using AI-powered diagnostics. Similar to TaskRabbit/Thumbtack with advanced AI automation.

## Architecture

```
├── customer_app/              # Customer-facing Flutter app
│   ├── lib/
│   │   ├── bootstrap/         # App initialization
│   │   ├── core/              # Core utilities & shared code
│   │   │   ├── constants/     # App constants, API endpoints
│   │   │   ├── errors/        # Exception types, Result<T>, error handler
│   │   │   ├── network/       # API client, connectivity service
│   │   │   ├── security/      # Secure storage
│   │   │   ├── theme/         # Light/dark themes, colors
│   │   │   ├── utils/         # Validators, formatters
│   │   │   └── widgets/       # Reusable widgets
│   │   ├── data/
│   │   │   ├── models/        # Data models (User, Booking, AI Analysis, etc.)
│   │   │   └── repositories/  # Data access layer
│   │   ├── features/          # Feature modules
│   │   │   ├── ai_assistant/  # AI diagnosis screens & provider
│   │   │   ├── auth/          # Login, signup, auth provider
│   │   │   ├── booking/       # Booking CRUD, provider matching
│   │   │   ├── chat/          # AI + human hybrid chat
│   │   │   ├── home/          # Dashboard, service categories
│   │   │   ├── profile/       # User profile
│   │   │   ├── reports/       # Service reports, cost breakdown
│   │   │   ├── reviews/       # Rating & review system
│   │   │   ├── safety/        # Emergency, location sharing
│   │   │   └── settings/      # App settings, dark mode, language
│   │   ├── providers/         # Global state (theme, locale)
│   │   ├── routes/            # GoRouter navigation
│   │   ├── services/          # External service integrations
│   │   │   ├── ai/            # AI service (OpenAI/Gemini)
│   │   │   ├── analytics/     # Event tracking
│   │   │   ├── feature_flags/ # Feature flag management
│   │   │   ├── location/      # Geolocation
│   │   │   ├── stripe/        # Payment processing
│   │   │   └── supabase/      # Backend service
│   │   └── l10n/              # Localization (EN, ES)
│   └── test/                  # Unit & widget tests
├── provider_app/              # Provider-facing Flutter app
│   └── lib/screens/           # Dashboard, bookings, earnings, profile
└── supabase/
    ├── schema.sql             # Database schema with RLS policies
    └── functions/             # Edge Functions (AI, payments)
```

## Features

### Core (10 Must-Have Features)
1. **AI Assistant System** - Structured JSON diagnosis with confidence scores, multi-cause analysis, safety disclaimers
2. **Smart Booking System** - Auto provider matching, live tracking, instant/scheduled booking
3. **Price Lock System** - AI estimated price ranges, lock pricing to prevent fraud
4. **Video Pre-Inspection** - Video call capability before booking
5. **Trust System** - Provider verification, ratings, reviews, work history, before/after images
6. **Smart Chat** - AI + human hybrid chat with real-time messaging
7. **Safety System** - Emergency button, live location sharing, safety tips
8. **Reports System** - Post-service reports, cost breakdown, warranty info
9. **AI Suggestions** - DIY fix steps, preventive maintenance tips
10. **Instant Mode** - Fast service booking within 30-60 minutes

### Advanced Features
- **Auto-Solve Engine** - AI suggests complete solutions, not just bookings
- **Smart Pricing AI** - Dynamic price suggestions via edge functions
- **User Memory** - Repeat issue detection across sessions
- **Hyperlocal Intelligence** - Location-based provider matching
- **Feature Flags** - Runtime feature toggle system
- **Analytics Tracking** - Event-based analytics for all user actions
- **Error Handling** - Sealed `Result<T>` pattern, comprehensive exception types
- **Secure API Handling** - API keys in Supabase Edge Functions only

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Frontend | Flutter 3.41+ / Dart 3.11+ |
| State Management | Provider |
| Navigation | GoRouter |
| Backend | Supabase (Auth, DB, Storage, Edge Functions) |
| AI | OpenAI GPT-4o (via Edge Functions) |
| Payments | Stripe |
| Localization | EN + ES (ARB files) |
| Theme | Material 3, Light + Dark mode |

## Prerequisites

- Flutter SDK 3.41.8+
- Dart SDK 3.11.5+
- A Supabase project
- An OpenAI API key
- A Stripe account

## Setup Instructions

### 1. Clone & Install Dependencies

```bash
git clone https://github.com/sand1432/tasktro.git
cd tasktro

# Customer app
cd customer_app
flutter pub get

# Provider app
cd ../provider_app
flutter pub get
```

### 2. Configure Supabase

1. Create a project at [supabase.com](https://supabase.com)
2. Run the SQL schema:
   - Go to SQL Editor in Supabase Dashboard
   - Copy and paste `supabase/schema.sql`
   - Execute to create all tables, RLS policies, indexes, triggers, and seed data
3. Enable authentication providers:
   - Email/Password (enabled by default)
   - Google OAuth
   - Apple OAuth

### 3. Configure API Keys (Secure Way)

**IMPORTANT**: API keys are NOT stored in the Flutter app. They are managed via Supabase Edge Functions.

Update `customer_app/lib/core/constants/app_constants.dart`:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
static const String stripePublishableKey = 'pk_test_YOUR_KEY';
```

Set Edge Function secrets via Supabase CLI:

```bash
supabase secrets set OPENAI_API_KEY=sk-your-key
supabase secrets set STRIPE_SECRET_KEY=sk_test_your-key
```

### 4. Deploy Edge Functions

```bash
cd supabase
supabase functions deploy analyze-issue
supabase functions deploy create-payment-intent
```

### 5. Create Storage Buckets

In Supabase Dashboard > Storage:
- `profile-images` (public)
- `service-images` (public)
- `before-after-images` (public)
- `chat-attachments` (private)
- `video-inspections` (private)

### 6. Run the App

```bash
cd customer_app
flutter run

# Or for provider app
cd provider_app
flutter run
```

## Testing

```bash
cd customer_app

# Unit tests
flutter test test/core/
flutter test test/data/

# Widget tests
flutter test test/features/

# All tests
flutter test

# Integration tests (requires emulator/device)
flutter test integration_test/
```

## Testing AI Responses

The AI service returns structured JSON via Supabase Edge Functions. To test:

1. Deploy the `analyze-issue` edge function
2. Use the AI Analysis screen in the app
3. Describe a home problem (e.g., "My kitchen faucet is leaking from the base")
4. The AI returns:
   - Problem identification
   - Multiple possible causes with probability scores
   - Estimated cost range
   - Urgency level (low/medium/high/critical)
   - Confidence score (0-100%)
   - DIY fix steps
   - Preventive tips
   - Safety disclaimers

Example AI response:
```json
{
  "problem": "Leaking kitchen faucet at the base",
  "causes": [
    {"cause": "Worn O-ring", "probability": 0.6, "explanation": "Most common cause"},
    {"cause": "Corroded valve seat", "probability": 0.3, "explanation": "Mineral buildup"},
    {"cause": "Loose connection", "probability": 0.1, "explanation": "Vibration over time"}
  ],
  "estimated_cost_min": 50,
  "estimated_cost_max": 200,
  "urgency_level": "medium",
  "confidence_score": 0.85,
  "safety_disclaimer": "Turn off water supply before attempting any repair",
  "diy_steps": ["Turn off water supply", "Remove faucet handle", "Replace O-ring"],
  "preventive_tips": ["Regular faucet maintenance", "Check connections annually"],
  "suggested_service_category": "plumbing"
}
```

## Security

- API keys (OpenAI, Stripe secret) are stored as Supabase Edge Function secrets
- Only the Supabase anon key and Stripe publishable key are in the Flutter app
- Row Level Security (RLS) enforces data access at the database level
- Sensitive user data is encrypted via Flutter Secure Storage
- Authentication uses Supabase Auth with JWT tokens

## Localization

The app supports English and Spanish. Language files are in `customer_app/lib/l10n/`:
- `app_en.arb` - English
- `app_es.arb` - Spanish

Switch languages in Settings > Language.

## License

MIT
