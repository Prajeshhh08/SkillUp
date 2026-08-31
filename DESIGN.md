# SkillUp Mobile Application Flow & Design System

## Project Overview
- **Project Name:** SkillUp (Emerald Cooperative App Interface)
- **Stitch Project ID:** `3027768114125438284`
- **Primary Color:** Deep Emerald (`#145C4C`)
- **Primary Fill / Container:** Mint Soft (`#E8F4F1`)
- **Background:** Pure White (`#FFFFFF`)
- **Surface / Inputs:** Soft Neutral Light (`#F8FAF9`)
- **Text Primary:** Charcoal Dark (`#111827`)
- **Text Secondary:** Cool Muted Gray (`#6B7280`)
- **Border & Dividers:** Subtle Gray (`#E5E7EB`)
- **Corner Radius:** Universal 12dp (8dp-16dp scale)
- **Typography:** `GoogleFonts.inter`

---

## Screen Inventory & Visual Specs

| Screen # | Screen Name | Route Path | Stitch Screen ID | Description & Visual Details |
|---|---|---|---|---|
| 1 | Splash Screen | `/splash` | `3a838ae90df74df48974fa152de1a042` | Full Deep Emerald (`#145C4C`) background with centered SkillUp white logo, clean typography, and smooth loading indicator. Auto-advances after 2 seconds. |
| 2 | Language Selection | `/language` | `209f9ff92c5e4953b22ab459d42957cb` | Top header with back button and brand logo, language selection cards (English, Tamil, Hindi, etc.) with active emerald borders and check indicators, and sticky primary Continue button. |
| 3 | Onboarding - Verified Workers | `/onboarding-1` | `124436cb5c0b403f9d36378ebd56a0f2` | Step 1 of 3 indicator, verified shield hero icon in layered ambient card, title, value description, top Skip button (jumps to `/location`), Next CTA button. |
| 4 | Onboarding - Fair Wages | `/onboarding-2` | `9b3322242ea047fd8876b49d64a48908` | Step 2 of 3 indicator, fair compensation & secure payments hero icon, title, value description, top Skip button, Next CTA button. |
| 5 | Onboarding - Welfare First | `/onboarding-3` | `4e4981dc8c9c481c955656834168d0c8` | Step 3 of 3 indicator, healthcare & emergency support hero icon, title, value description, and primary "Get Started" CTA button. |
| 6 | Location Permission | `/location` | `42b9c70e513d4535b7aa4328aa48cfa2` | Location pin hero with pulsing radar animation, explanatory copy, primary "Allow Location Access" button and secondary "Enter Location Manually" button. |
| 7 | Role Selection | `/role` | `34617b20ce804eb3a52989f8bfeb8ca9` | Two interactive cards: "Customer" (I want to hire workers) and "Worker" (I am a worker) with active border and tint selection, and dynamic Continue CTA. |
| 8 | Manual Address Setup | `/address` | `092f70038d06406d9d7d5fc27c56d448` | Search input, "Use current location" button, styled map preview card, Flat/Building, Street/Area, Landmark, and Pincode input fields, "Save as" tags (Home, Work, Other), and primary "Save & Finish Setup" CTA. |

---

## Route Configuration
- `/splash` -> `SplashScreen`
- `/language` -> `LanguageSelectionScreen`
- `/onboarding-1` -> `OnboardingScreen1`
- `/onboarding-2` -> `OnboardingScreen2`
- `/onboarding-3` -> `OnboardingScreen3`
- `/location` -> `LocationPermissionScreen`
- `/role` -> `RoleSelectionScreen`
- `/address` -> `AddressSetupScreen`