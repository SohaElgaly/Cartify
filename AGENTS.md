# Cartify working agreement

## Purpose and mentoring

Cartify is a SwiftUI e-commerce portfolio project. The user's primary goal is to learn to build and debug the app independently.

- Use simple explanations and work on one focused problem at a time.
- Explain the symptom, cause, proposed change, why each relevant line exists, and how to verify the result.
- If the user asks to learn or try a fix themselves, guide them without editing application code. If they ask to check their changes, review them and explain remaining issues rather than silently completing the exercise.
- When explicitly asked to implement changes, do the work, preserve unrelated edits, and explain the result afterward.
- Keep explanations in English by default; use Egyptian Arabic if requested or helpful to the user.
- Distinguish implemented, build-checked, and behavior-verified. Never claim a flow works end to end from build success or a preview alone.
- Use `MENTOR_NOTES.md` as project learning context. Its dated status can become stale; inspect current code before relying on it.

## Project layout and architecture

This directory is the Git repository root. The Xcode project is `Cartify.xcodeproj`; application source is under `Cartify/`.

- Keep the existing feature-based MVVM architecture with repository protocols and initializer dependency injection.
- Views display state and trigger actions. View models own screen state and validation. Repository implementations coordinate data operations. APIClient owns shared HTTP request/response mechanics.
- Keep feature endpoints and request/response models with their feature. Use an accurate model for each response shape; do not make required fields optional to hide contract mismatches.
- AppContainer constructs dependencies and view models. Avoid adding global networking singletons or constructing repositories inside view models.
- Use the existing Observation approach (`@Observable`, view-owned `@State`) and main-actor isolation for UI state.
- Let AuthFlowView own authentication navigation. Avoid nesting another NavigationStack inside LoginView.
- Reuse Shared design-system values and components. Do not add architecture layers, libraries, or large refactors without a concrete need.
- When changing a protocol, review all implementations, including preview fakes.

## Backend and authentication

- The configured backend is Railway. APIClient's base URL omits `/api`; endpoint paths include `api/...`. Do not accidentally duplicate the prefix or switch to the retired Render URL.
- The backend belongs to another developer. Treat handoff documents as API contracts to compare with observed behavior, not proof that a deployment or email delivery works.
- Login and registration return accessToken, refreshToken, and user. Refresh returns only accessToken and refreshToken; use a token-only response model for refresh.
- Save both rotated tokens in Keychain. Do not store credentials in UserDefaults or log passwords/reset codes/access or refresh tokens.
- Differentiate credential rejection from temporary connection/server failures. Keep session invalidation and token cleanup responsibilities explicit.
- Forgot Password's neutral success response does not prove account existence or email delivery. Email delivery is pending external verification; do not repeatedly send requests to diagnose it.
- The documented reset flow uses a full code copied from email. The email link opens a website; do not claim universal links are implemented. Trim surrounding reset-code whitespace, but do not modify passwords.
- The supplied API handoff documents simulated payment. Do not introduce a real payment SDK unless requirements change.

## Verification and Git

- Inspect the current branch, status, relevant code, and any more-specific AGENTS.md before changes. Authentication work is currently on `feature/authentication`; verify rather than assume.
- Preserve staged, unstaged, and untracked user work. Avoid broad staging or committing unrelated changes. Do not switch branches, commit, push, or merge merely because a handoff suggests it.
- Use focused checks appropriate to the change. Prioritize meaningful validation, decoding, session, retry, and navigation behavior over tests that repeat implementation details.
- Fake repositories and JSON fixtures are useful for offline verification. Do not change a real account's credentials just to verify UI behavior.
- A standard build from this directory is `xcodebuild -project Cartify.xcodeproj -scheme Cartify -sdk iphonesimulator -configuration Debug -derivedDataPath /tmp/cartify-reset-build CODE_SIGNING_ALLOWED=NO build`.
- Follow environment permission rules for Xcode/Simulator access. Report blocked or declined checks accurately; do not bypass a declined execution request.
- Do not treat keyboard/haptic console warnings as the cause of a network issue without evidence. Trace the relevant action through view, view model, repository, API client, and response.
- Report what was changed, what was checked, and what remains unverified. Keep fixes small enough for the user to understand and review.
