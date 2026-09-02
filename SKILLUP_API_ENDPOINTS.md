# SkillUp API Endpoints

This document lists the backend endpoints needed to turn the current Flutter UI into a functional SkillUp application. Protected endpoints should use `Authorization: Bearer <access-token>`.

## Authentication and account

| Method | Endpoint | Purpose |
| --- | --- | --- |
| POST | `/auth/register/customer` | Create a customer account. |
| POST | `/auth/register/worker` | Create a worker account. |
| POST | `/auth/login` | Sign in with phone/email and password. |
| POST | `/auth/otp/send` | Send an OTP. |
| POST | `/auth/otp/verify` | Verify an OTP. |
| POST | `/auth/password/reset` | Send password-reset instructions. |
| POST | `/auth/logout` | End the current session. |
| GET | `/me` | Return the signed-in user and role. |
| PATCH | `/me` | Update customer profile data and known jobs. |
| POST | `/me/terms-acceptance` | Save terms/privacy acceptance and accepted version. |

## Customer profile, metrics, and addresses

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/customers/me/profile` | Return name, email, phone, and known jobs. |
| GET | `/customers/me/metrics` | Return order acceptance percentage and booking totals. |
| GET | `/addresses` | List saved addresses. |
| POST | `/addresses` | Create an address. |
| PATCH | `/addresses/{addressId}` | Update an address. |
| DELETE | `/addresses/{addressId}` | Delete an address. |
| GET | `/locations/search?q=` | Address/place autocomplete. |
| GET | `/locations/reverse-geocode?lat=&lng=` | Convert GPS coordinates to an address. |

## Worker registration, profile, and verification

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/skill-categories` | List skills such as plumbing and carpentry. |
| GET | `/workers/me/profile` | Return worker profile and setup progress. |
| PATCH | `/workers/me/profile` | Save bio, skills, hourly rate, availability, and payout preference. |
| POST | `/workers/me/documents` | Submit identity and bank verification data. |
| POST | `/uploads/presign` | Create a secure direct-upload URL for documents. |
| GET | `/workers/me/verification-status` | Return verification status and checklist. |
| GET | `/workers/{workerId}` | Return a public worker profile. |
| GET | `/workers/{workerId}/reviews` | Return worker reviews. |

## Service discovery and matching

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/categories` | List service categories. |
| GET | `/services?categoryId=` | List services in a category. |
| GET | `/services/{serviceId}` | Return service details, duration, inclusions, and price. |
| GET | `/search?q=&rating=&distance=&availableNow=&maxPrice=` | Search/filter services and workers. |
| GET | `/workers/nearby?lat=&lng=&serviceId=` | Return nearby verified workers. |
| GET | `/workers/map?lat=&lng=&serviceId=` | Return worker map markers. |
| POST | `/matching/emergency` | Start an urgent worker-matching request. |

## Booking and order lifecycle

| Method | Endpoint | Purpose |
| --- | --- | --- |
| POST | `/bookings/quote` | Calculate a booking quote before review. |
| POST | `/bookings` | Create a booking. |
| GET | `/bookings?status=` | List active, completed, or cancelled bookings. |
| GET | `/bookings/{bookingId}` | Return booking/order details. |
| PATCH | `/bookings/{bookingId}` | Update address, time, notes, or service choices. |
| POST | `/bookings/{bookingId}/cancel` | Cancel with a reason. |
| POST | `/bookings/{bookingId}/reschedule` | Choose a new date/time. |
| GET | `/bookings/{bookingId}/tracking` | Return current booking status, worker, timeline, and ETA. |
| POST | `/bookings/{bookingId}/rebook` | Repeat a previous booking. |
| POST | `/bookings/{bookingId}/review` | Submit a rating and review. |
| GET | `/bookings/{bookingId}/invoice` | Return invoice/receipt details and download link. |

## Worker job handling

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/worker/bookings?status=` | List offered, active, and completed jobs. |
| POST | `/worker/bookings/{bookingId}/accept` | Accept a booking. |
| POST | `/worker/bookings/{bookingId}/decline` | Decline a booking. |
| PATCH | `/worker/bookings/{bookingId}/status` | Update status: on the way, started, or completed. |
| GET | `/worker/metrics` | Return acceptance rate, completed jobs, and earnings. |

## Payments

| Method | Endpoint | Purpose |
| --- | --- | --- |
| POST | `/payments/intents` | Start UPI/card/net-banking payment. |
| POST | `/payments/webhook` | Receive payment gateway status updates (backend-only). |
| GET | `/payments/{paymentId}` | Return payment status. |
| POST | `/worker/payout-accounts` | Save worker bank or UPI payout account. |

## Realtime updates

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/bookings/{bookingId}/tracking/stream` | WebSocket or SSE stream for live tracking updates. |

## Security notes

- Do not store passwords, Aadhaar/PAN values, or bank information as plain text.
- Use a payment gateway for all card and UPI payment processing.
- Use secure object-storage uploads for identity documents.
