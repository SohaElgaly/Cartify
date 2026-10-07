# Cartify — beginner study notes and development plan

Reviewed: 1 October 2026. Branch: `feature/authentication`.

These notes describe the current iOS source, our observed debugging results, and the supplied `IOS_HANDOFF.md`. Backend behavior described by the handoff is a contract to verify, not proof of deployment or delivery. Email-delivery investigation is pending with the backend developer. No application behavior was changed while preparing these notes.

**1. What you are building**

Cartify is an iOS shopping app. The intended journey is: create an account, sign in, browse products, add products to a cart, and place an order.

You are building the iOS client. Another developer owns the backend. The app collects input, makes requests, and shows results. The backend verifies accounts, stores business data, checks permissions and stock, calculates order totals, and sends reset emails through its email provider.

The current app has authentication screens, Home, and Product Details. It is not yet a complete shopping app.

**2. What exists, and what we have verified**

| Area | Current evidence | What remains |
| --- | --- | --- |
| Login and registration | API integration exists; successful flows were reported earlier; duplicate email rejection was observed | Failure cases, input normalization, and repeatable regression checks |
| Normal logout | Logs showed repository success followed by session logout | Expired credentials, offline behavior, and visible failure feedback |
| Session restoration | Reads stored tokens; persistence was reported working | Correct handling of rejected/expired credentials and invalidation |
| Token refresh | Missing refresh call was added; a refresh request returning 401 was observed | Correct response model, reliable invalidation, and successful refresh/retry verification |
| Forgot Password | Sends email request; screen now displays progress, success, and failure | Existing email validator is not called; email input is not trimmed; delivery is pending |
| Reset Password | Code entry, password confirmation, API call, errors, success UI, and return-to-login navigation exist | Real emailed-code reset and subsequent login are not verified |
| Reset previews | Fake success and invalid-code repositories exist | Previews are not automated tests or proof of live backend behavior |
| Home | Fetches API data; displays categories and featured products; filters featured titles locally | Category behavior, real banners/new arrivals, error feedback, user greeting |
| Product Details | Fetches and displays a product | Optional-value crash risks, real retry actions, cart integration |
| Cart, checkout, orders, profile, wishlist | Not implemented as app features | Planned work |
| Build | Most recent Simulator build succeeded | Build success does not verify user journeys |
| Automated tests | No dedicated test target/suite found in the project | Add focused tests for meaningful behavior; earlier temporary offline checks were not completed |

The branch has existing staged, unstaged, and untracked work. Review it before creating commits. Do not assume every change belongs to the latest task.

**3. The technologies, in ordinary language**

| Technology or technique | What it means | How Cartify uses it |
| --- | --- | --- |
| Swift | The programming language | Models, networking, validation, and application logic |
| SwiftUI | Apple's way to describe interfaces using Swift | Login forms, product cards, navigation, loading indicators |
| Foundation | Common Apple utilities | URLs, requests, JSON, strings, errors |
| Observation / `@Observable` | Makes property changes observable by SwiftUI | View-model state and authentication state |
| `@State` | Keeps view-owned state across SwiftUI view updates | View models and navigation path |
| Bindings (`$`) | A connection that can both read and write a value | Text fields update view-model properties |
| `@MainActor` | Isolates UI-facing state to the main actor | View models and `AuthSession` |
| `async` / `await` | Allows work to suspend while awaiting a result | Network requests without blocking the UI while waiting |
| `URLSession` | Apple's HTTP networking API | Sends requests to Railway |
| `Encodable` / `Decodable` | Converts Swift values to/from structured data | JSON request bodies and responses |
| REST API / HTTP | A server interface built around URLs and request methods | `POST` login/reset, `GET` Home/product |
| Keychain / Security | Apple's protected credential storage | Access and refresh tokens |
| `NavigationStack` | A stack of screens and their history | Authentication routes and product navigation |
| `AsyncImage` | Loads and displays an image from a URL | Wrapped by `NetworkImage` with placeholder/loading states |
| Xcode / Simulator / LLDB | Build, run, and inspect an app | Builds, breakpoints, variables, console output |
| Git | Tracks changes and supports separate branches | Authentication work on `feature/authentication` |

MVVM, dependency injection, and the repository pattern are design techniques, not libraries. Current Xcode settings target iOS 26.2 and enable MainActor as the default actor isolation. No third-party package dependencies are listed. Cartify does not currently use Firebase Auth, Alamofire, Swinject, Core Data, or SwiftData. Those may belong to earlier projects, not this app.

**4. The architecture: who does what?**

The request path is:

```text
User action
    ↓
View → ViewModel → Repository protocol
                        ↓ implemented by
                 Remote Repository → APIClient → URLSession → Backend
```

Data returns through the calls. The view model updates its observable state, and SwiftUI redraws the parts of the view that use that state.

The protocol is a contract, not an extra object or another network hop.

| Piece | Question it answers | Cartify example |
| --- | --- | --- |
| View | What does the user see and tap? | `LoginView` |
| ViewModel | What happens after the tap, and what state should the screen show? | `LoginViewModel` |
| Model | What data do we send or receive? | `LoginRequest`, `User`, `Product` |
| Repository protocol | Which data operations are available? | `AuthRepository` |
| Remote repository | How do we perform those operations with this API? | `AuthRemoteRepository` |
| Endpoint | What path, method, headers, and body describe one request? | `AuthEndpoint.login(request)` |
| APIClient | How do all requests get sent, checked, and decoded? | `APIClient.send` |
| Token storage | Where do credentials persist? | `TokenStorage` |
| Session state | Should the app show authenticated or unauthenticated UI? | `AuthSession` |
| Composition root | Who creates these objects and connects them? | `AppContainer` |

MVVM stands for Model–View–ViewModel. It separates the screen from its presentation logic. Repositories, dependency injection, and the API client support MVVM; they are not additional letters in its name.

**5. Follow one complete login request**

1. The user types into `LoginView`. Bindings update `viewModel.email` and `viewModel.password`.
2. Sign In starts a `Task` and calls `await viewModel.login()`.
3. The view model clears the previous error and sets `isLoading = true`.
4. It creates `LoginRequest(email:password:)` and calls the injected repository.
5. `AuthRemoteRepository` selects `AuthEndpoint.login(request)` and asks `APIClient` to send it.
6. The endpoint supplies `POST`, `api/auth/login`, JSON headers, and the encoded body.
7. `APIClient` builds a `URLRequest`; `URLSession` sends it.
8. The backend validates the credentials and responds.
9. The client checks the HTTP status and decodes the JSON into Swift types.
10. The repository saves the access and refresh tokens in Keychain and returns the authentication data.
11. The view model calls `authSession.authenticate()`.
12. `AuthFlowView` observes the state change and shows Home.
13. `defer` resets the view model's loading flag when its method exits.

If the request throws, the view model's `catch` assigns an error message instead. The view displays that state. The current login code prints the user but does not retain a current-user model for Profile or Home; Home still uses a hardcoded greeting.

**6. Dependency injection and protocols**

Dependency means an object needs another object to do its job. A view model needs a repository.

```swift
init(repository: AuthRepository) {
    self.repository = repository
}
```

The initializer receives that dependency instead of constructing a remote repository internally. This is initializer dependency injection.

`AuthRepository` is a protocol: a list of required operations. `AuthRemoteRepository` implements those operations using the API. A fake repository can implement the same operations using predetermined results.

The benefit is practical: the reset screen can show success or an expired-code error in a preview without changing a real password or depending on Railway.

`AppContainer` constructs shared services and builds view models. Its `make...ViewModel()` methods are factories: methods that construct objects with the correct dependencies.

Important distinction: this app DOES have `AppContainer.shared`. It is not completely free of global access. However, `APIClient` itself is injected, and the view models receive repository dependencies. As features grow, keep container access near screen construction rather than reaching for it inside business logic.

**7. Understand the Swift syntax we keep using**

```swift
Button {
    Task {
        await viewModel.resetPassword()
    }
} label: {
    Text("Reset Password")
}
```

`Button` has two closures: code to run after tapping, and code describing its appearance. A closure is a block of behavior that can be passed around. `Task` starts asynchronous work from the synchronous button action. `await` marks a call that may suspend the task. It does not mean every operation automatically runs on a background thread.

The view-model method catches errors internally, so this view does not need `try`. The repository method can throw, so the view model calls it using `try await`.

```swift
guard !isLoading else { return }
isLoading = true
defer { isLoading = false }
```

`guard` requires a condition to be true; otherwise it exits early. `!` means “not” here. `defer` schedules cleanup for when the current scope exits, including an exit caused by an error. This avoids forgetting to turn the spinner off.

```swift
if let error = viewModel.errorMessage {
    Text(error)
}
```

`errorMessage` is optional: it may contain a string or `nil`. `if let` safely unwraps it. No message means no error text is shown.

```swift
private(set) var isLoading = false
```

Other objects can read this state, but only the type can set it. The screen asks for an operation; the view model controls that operation's state.

`final class` prevents subclassing; it does not make the object's properties immutable. `let` prevents reassignment of a stored value/reference; `var` permits reassignment.

`@State private var viewModel` preserves the view-owned reference across view updates. `@Observable` makes the properties read by the view observable. `$viewModel.password` provides a binding the field can write through. None of these annotations saves data to disk.

**8. Requests, responses, and generics**

A request model is what we send, such as `ResetPasswordRequest`. It conforms to `Encodable`. A response model is what we receive, such as `AuthData`. It conforms to `Decodable`. `Codable` means both.

```swift
APIResponse<AuthData>
APIResponse<HomeResponse>
```

These share the same outer structure but have different types inside `data`. The generic placeholder `T` lets one envelope describe both without copying its definition.

```swift
func send<T: Decodable>(...) async throws -> T
```

This means “send a request and return the requested type, provided that type can be decoded.” The caller's expected type determines what the decoder attempts to build.

For message-only responses, the app uses `APIMessageResponse`. Keeping a separate message type is valid; we do not need to adopt every sample type from a backend document word for word.

Nonoptional response fields must exist with the expected type. Making every property optional would hide contract errors. Use an accurate model for each response.

Concrete current defect: login returns tokens plus `user`, but refresh returns only tokens according to the latest handoff. Both refresh implementations currently decode `AuthData`, which requires `user`. We need a token-only response model and must update both call paths. This is a documented contract mismatch, separate from the refresh 401 we observed.

**9. Authentication: three different tokens and two kinds of state**

| Item | Purpose | Lifetime in the supplied handoff |
| --- | --- | --- |
| Access token | Authorize authenticated API requests | 15 minutes |
| Refresh token | Obtain replacement access and refresh tokens | 7 days |
| Password-reset token | Prove possession of the reset email when choosing a new password | 15 minutes |

The reset token is not the access token. The API does not require an access token for forgot/reset password. Tokens should not be pasted into chat or written into debug logs.

Keychain is persistent credential storage. `AuthSession.state` is in-memory UI state. Setting the state to unauthenticated does not, by itself, delete Keychain items or revoke server sessions.

Current normal logout: server request succeeds → repository clears Keychain → view model changes session state → Login appears.

Current failed-refresh path: API client changes session state but leaves the stored tokens. On a later launch, `restoreSession()` checks token presence and may show authenticated UI again. The server still controls actual access; the local flag does not bypass server authorization.

Desired refresh behavior: authenticated request receives `TOKEN_EXPIRED` → refresh once → save both replacement tokens → retry with new access token. The handoff says the previous refresh token becomes invalid and only one session per account is supported.

The implementation still needs work. Its `catch` covers BOTH refreshing and retrying, so even a temporary error during retry currently changes authentication state. We should distinguish rejected credentials from temporary transport/server errors, give session invalidation one clear owner, and coordinate simultaneous refresh attempts.

**10. What we changed together**

| Change | Why |
| --- | --- |
| Called the existing `refreshAccessToken()` before retry | The previous code printed “refreshed” without actually refreshing |
| Added refresh-failure diagnostics | We needed evidence about why the refresh endpoint returned 401 |
| Preserved ordinary API error codes/messages | A plain HTTP number cannot distinguish invalid reset codes from other failures |
| Removed unnecessary nested login navigation during mentoring | One stack now owns the authentication path |
| Added Forgot Password loading/success/error feedback | A request should not appear to do nothing |
| Added Reset Password view model and screen | Validate input, submit the request, and show the result |
| Added editable reset-code input | New handoff documents copying the full token from email |
| Trimmed reset-code edges, but not passwords | Pasting may add whitespace; passwords must retain intentional characters |
| Added forgot/reset routes and back-to-login behavior | Both screens are tracked by the same navigation path |
| Added fake reset previews | Explore success and invalid-code UI without live API calls |

We adapted the client to the backend contract. We did not configure Brevo, change the server, or verify real email delivery.

**11. Navigation in simple terms**

`AuthFlowView` decides whether to show Home or the authentication stack. `AuthRoute` names possible authentication destinations.

```text
path = []                                  → Login
path = [.forgotPassword]                    → Forgot Password
path = [.forgotPassword, .resetPassword]    → Reset Password
```

`NavigationLink(value:)` adds a destination value. `.navigationDestination(for:)` maps that value to a screen. `path.removeLast()` goes back one step; `path.removeAll()` returns to the stack's root Login screen.

The new flow is Login → Forgot Password → “I have a reset code” → Reset Password → Back to Sign In. There are no configured universal links in this flow. The email button opens a website; users manually paste the email code into the app.

We should also check that the path is reset appropriately when authentication changes, so a later logout does not resurrect an old Register/Forgot Password destination.

**12. Debugging: what our errors taught us**

| Evidence | What it proves | What it does not prove |
| --- | --- | --- |
| Build succeeded | The project compiled and packaged for that build | The network or user journey works |
| Breakpoint at refresh call | Execution reached that line | The call has completed successfully |
| `401 TOKEN_EXPIRED` from refresh | Backend rejected that refresh as expired | Why it became expired or whether all other refresh cases work |
| `409` / email already exists | Registration recognized a duplicate account under its rules | Reset email was sent |
| Forgot Password `success: true` | Request completed with the neutral response | Account lookup succeeded, Brevo accepted a send, or the email arrived |
| `NSURLErrorDomain -1001` | Network operation timed out | Server did nothing, or Brevo is definitely responsible |
| Keyboard constraint/haptic warnings | Input-system warnings were emitted | They caused email delivery failure |

For a confusing failure, trace: tap → view-model method → repository → network request → response/error → state update → visible UI. Fix the first unsupported assumption rather than editing several layers at once.

Transport error: could not complete the network operation. HTTP/API error: got a response reporting failure. Decoding error: got data, but it did not match the expected Swift type. These need different investigations.

For email delivery, the backend developer must trace account lookup, provider submission, and provider delivery status. Keep that item pending while progressing on independent app work.

**13. What keeps this architecture clean?**

1. Views describe UI and trigger actions. Do not place URL construction, token storage, or response decoding in a button action.
2. View models hold screen state and validation. They should not manipulate a `NavigationStack` directly or invent backend data.
3. Repositories represent feature operations. The remote implementation knows which endpoint to use.
4. APIClient owns common HTTP mechanics. Avoid copying networking into every feature.
5. Endpoint cases describe individual requests. Feature endpoints remain in their feature folders.
6. AppContainer connects objects. Do not construct an entire dependency tree inside each view model.
7. Shared UI is genuinely shared. Put repeated colors, typography, and components in Shared; keep one-off screens with their feature.
8. Use protocols where substitution helps. Do not create a protocol for every struct or add layers just to look advanced.
9. Define clear ownership of session invalidation and cart state. Several objects independently deleting tokens or updating cart totals creates inconsistent behavior.
10. Match API contracts. Keep optional fields optional, and keep business authority such as prices, stock, and permissions on the server.

The current architecture has compromises: Core/APIClient depends directly on feature auth types and `AuthSession`; some views access `AppContainer.shared`; refresh logic exists in two places. We can improve these when fixing authentication without introducing a new architecture across the whole project.

Some validation is stricter than the handoff: registration/reset currently require letters and numbers, while the handoff specifies at least eight characters. Confirm the intended product rule before changing it. A client rule is not automatically a backend requirement.

**14. Interview questions and honest sample answers**

**“Tell me about Cartify.”**

“Cartify is a SwiftUI shopping app I am building. It integrates with a REST backend through URLSession. I organize features using MVVM, inject repositories into view models, and store authentication tokens in Keychain. I have implemented authentication screens and product browsing. I am currently hardening authentication and testing the password-reset integration before completing cart and checkout.”

**“Why MVVM?”**

“It separates screen layout from presentation logic. LoginView displays fields and state; LoginViewModel coordinates login. This makes the code easier to understand and lets me test the view model with a fake repository.”

**“Why a repository protocol?”**

“The view model needs a login operation, not details about URLs. AuthRepository describes the operation. The remote implementation uses the API, while a fake can return a controlled result in previews or tests.”

**“What is dependency injection?”**

“I pass required objects into an initializer. AppContainer creates the repository and supplies it to the view model. This avoids hardwiring the view model to a particular remote service.”

**“How does SwiftUI know to update?”**

“The view reads properties from an observable view model. When those properties change, SwiftUI updates the affected UI. State preserves the view-owned model, and bindings let inputs edit its properties.”

**“Does async mean background thread?”**

“No. Await allows suspension. URLSession performs the network operation asynchronously, while my view models are main-actor isolated for UI state. CPU-heavy synchronous work would still need separate consideration.”

**“How do you handle authentication?”**

“Login returns access and refresh tokens. I store them in Keychain and attach the access token to protected requests. The intended expiration flow is refresh, save rotated tokens, and retry once. I am fixing response-model and invalidation edge cases, so I would not claim every refresh scenario is verified yet.”

**“Why Keychain instead of UserDefaults?”**

“Tokens are credentials. I use Apple's credential-storage facility rather than ordinary preferences. The password is sent for authentication but is not persisted by my app.”

**“Describe a bug you investigated.”**

“An expired-token path printed success but retried without calling the refresh method. I traced it with breakpoints, added the missing call, then inspected the real refresh error. That showed why a success log is not evidence unless it follows the operation it describes.”

**“How did you diagnose missing reset emails?”**

“The iOS request returned a neutral success response that intentionally hides account existence. I separated client success from email delivery, checked duplicate registration behavior, and asked the backend developer to inspect provider logs. I did not assume a 200 response meant an email reached the inbox.”

**“How would you test this?”**

“I would inject fake repositories to test input validation, loading cleanup, errors, and successful state changes. For APIClient, I would use a custom URLProtocol with an injected URLSession to control HTTP responses. I would add UI checks for navigation, and verify real email/reset/login separately.”

**“Did you build the backend?”**

“Another developer provides the backend. My work is iOS integration, state management, UI, and diagnosing the boundary between the app and API.”

**“Does it support offline storage or real payment?”**

“Not currently. Tokens persist in Keychain, but that is different from offline product/cart storage. The backend handoff documents simulated payment; no real payment SDK has been integrated.”

Do not claim complete authentication, automated test coverage, a working cart, real payments, deep links, or ownership of backend email configuration. Explain what you built, what you verified, and what you would improve.

**15. Our next steps, in order**

| Stage | Small deliverables | Done when |
| --- | --- | --- |
| A. Authentication reliability | Token-only refresh model; one clear refresh path; invalid-session cleanup; transient-error policy; visible logout failures; forgot-email validation; navigation reset checks | Controlled success/failure cases behave predictably and relaunch does not revive rejected credentials |
| Pending backend item | Email delivery and actual reset-code integration | Real code arrives; reset works; new password logs in; old password is rejected; expired code shows useful feedback |
| B. Product safety | Remove unsafe optional unwraps; match nullable brand and actual variant shape; connect retry buttons; display Home errors | Missing fields and failed requests show useful UI without crashing |
| C. App shell and Profile | Native TabView; Home and Profile first; real user identity; relocate Logout | Tabs preserve sensible navigation and Profile displays actual user information |
| D. Product discovery | Category filtering; server search; query parameters; pagination; banner/new-arrival integration where supported | Users can find products beyond Home's featured list; empty/loading/error states work |
| E. Cart | Cart models/repository/view model; add, update, remove; shared count; stock errors | Add-to-cart updates the cart consistently, and server results determine totals |
| F. Checkout and orders | Address selection, optional coupon, create order, simulated payment, orders list | Complete test purchase works; stock/price changes and failures are handled |
| G. Portfolio polish | Accessibility, layout, screenshots, README, targeted regression tests, logging cleanup | Another developer can run and understand the project; claims match verified behavior |

Wishlist and reviews are useful later increments. Reviews require delivered orders according to the handoff, so coordinate a backend test account/order rather than inventing eligibility in the app.

Do not let the external email blocker stop independent learning, but keep password reset marked unverified. Finish a stable authentication checkpoint before piling cart state on top of broken sessions.

Important dependencies: APIClient currently declares no URL query construction despite EndPoint having `queryItems`; implement that before server search/pagination. Product Details currently force-unwraps stock, description, and variants; fix that before expanding its interactions. Banners and new arrivals are fetched but not rendered as actual dynamic sections. The Banner model is empty.

The latest backend contract uses simulated payment. We do not need to introduce PayPal, Stripe, or Apple Pay to complete that documented MVP. Revisit real payment only if product requirements change.

**16. How we will plan each feature**

Write one small feature card before coding:

```text
User goal:
What should the user accomplish?

API contract:
Method, path, auth requirement, request, response, error codes.

State:
What will idle, loading, success, empty, and failure look like?

Ownership:
Which model, repository, view model, and view are responsible?

Acceptance checks:
One normal case, one invalid-input case, one server/network failure.

Out of scope:
What are we deliberately postponing?
```

Example for “Add to cart”: user taps Add on a product; POST `/cart/items` with product ID and integer quantity; token required; server returns updated cart; handle insufficient stock; show progress and result; do not build checkout or offline synchronization in the same change. Do not silently retry a timed-out add, because that endpoint increments quantity and the server may already have processed it.

Implement a small complete slice: model/endpoint → repository → view model → view → verify. Use the existing layers and conventions. Add an abstraction only when you can explain the concrete problem it solves.

For tests, prioritize behavior: refresh retries once, rejected credentials are cleared, invalid inputs do not call the repository, failure releases loading, and navigation returns to the correct root. Do not write tests that merely repeat a property assignment.

For Git, inspect status and diff; stage only the relevant files or hunks; make one understandable commit per verified change. Example: `fix(auth): decode token-only refresh response`. Do not commit all unrelated staged work, merge the feature branch, or claim a full feature is complete while required acceptance checks remain pending.

**17. How we will work together as mentor and learner**

For each step: explain the user-visible problem → read the smallest relevant code path → predict what it should do → make one focused change → explain new syntax and responsibility → verify the result → record what remains.

We will distinguish three levels of confidence: implemented, build-checked, and behavior-verified. A successful preview is not a real backend test. A successful API response is not proof of an email arriving. A correct UI state is not proof that stored credentials were deleted.

Suggested reading order: start with sections 4 and 5, then 6 and 7. Trace Login once in Xcode before studying all of authentication. Next compare that path with Reset Password. After you can explain both in your own words, tackle the refresh response-model fix as our next coding exercise.

**First exercise:** explain why `LoginViewModel` depends on `AuthRepository`, while `AuthRemoteRepository` depends on `APIClient`. Name one thing each layer should not need to know.
