# Backend Architecture Plan - Firebase Implementation

This plan outlines the architecture for migrating the local-state Reminder App to a collaborative Firebase-backed application.

## User Review Required

> [!IMPORTANT]
> **Data Migration**: This plan assumes we are starting fresh or syncing current local data to Firebase once. Old local data might need a migration strategy if users want to keep it.
>
> **Authentication**: We will use **Firebase Phone Authentication**. To avoid SMS limits and costs, we will use **Fixed Test Numbers** (e.g., `+1 555-123-4567` with PIN `123456`). This simulates a premium "Phone + OTP" experience for free.

## Architecture Overview

We will use a **service-oriented architecture** to keep UI code clean and separate from Firebase logic.

### 0. Missing Screens & UI Components
We need to create the following screens to support the auth flow:
- `LoginScreen.dart`: Input phone number.
- `OtpVerificationScreen.dart`: Input 6-digit OTP (Pin).
- **`ProfileSetupScreen.dart`**: (NEW) Since Phone Auth only gives us a number, new users MUST see this screen to enter their **Name** and **Role** before entering the app.
- `SignUpScreen.dart`: (Removed/Merged) The "SignUp" logic is just Login -> if new user -> ProfileSetupScreen.

### 1. Firestore Schema Design

#### **`users` Collection**
Stores user profiles and family association.
```json
{
  "uid": "string (Auth UID)",
  "email": "string",
  "displayName": "string",
  "familyId": "string (Reference to families document)",
  "role": "string ('admin' | 'member' | 'child')",
  "fcmToken": "string (For future push notifications)",
  "createdAt": "timestamp"
}
```

#### **`families` Collection**
Groups users together for shared tasks.
```json
{
  "id": "string (Auto-ID)",
  "name": "string (e.g., 'Smith Family')",
  "joinCode": "string (Unique 6-digit code for invites)",
  "memberIds": ["string (UIDs)"],
  "admins": ["string (UIDs)"],
  "createdAt": "timestamp"
}
```

#### **`tasks` Collection**
The core unit of work.
```json
{
  "id": "string (Auto-ID)",
  "familyId": "string (Indexable for queries)",
  "title": "string",
  "description": "string",
  "status": "string ('urgent' | 'critical' | 'standard')",
  "dueDate": "timestamp",
  "isDone": "boolean",
  "assigneeIds": ["string (UIDs)"],
  "createdById": "string (UID)",
  "photoProofUrl": "string (Nullable)",
  "photoProofRequired": "boolean",
  "createdAt": "timestamp"
}
```

#### **`audit_logs` Collection**
For the "Transparency Log" feature.
```json
{
  "id": "string",
  "familyId": "string",
  "action": "string (e.g., 'Hazrat completed task X')",
  "userId": "string",
  "userName": "string (Snapshot for display)",
  "timestamp": "timestamp"
}
```

### 2. Service Layer

We will implement the following services in `lib/services/`:

-   **`AuthService`**: Wraps `FirebaseAuth`. Handles `verifyPhoneNumber`, `signInWithCredential` (OTP), `signOut`, `getCurrentUser`.
-   **`FirestoreService`**: Generic database wrapper or specific methods using `cloud_firestore`.
    -   `getFamilyTasks(familyId)`
    -   `addTask(task)`
    -   `updateTask(taskId, data)`
    -   `streamTask(taskId)`
    -   `joinFamily(code)`
-   **`StorageService`**: Wraps `FirebaseStorage` for uploading photo proofs.
    -   `uploadTaskProof(file, taskId)`

### 3. State Management Updates

We will refactor existing Providers to use these services instead of local lists.

-   **`TaskProvider`**:
    -   **Current**: `List<Map> _tasks = [...]`
    -   **New**: `StreamSubscription` to Firestore `tasks` collection. Local list updates automatically from stream.
-   **`AuthProvider` (New)**:
    -   Manages current user state and family context.

## Proposed Logic Flow

1.  **App Start**: Check Auth State.
    *   If Logged Out -> Show `LoginScreen`.
    *   If Logged In -> **Check Firestore `users/{uid}`**:
        *   If Document Missing -> Show `ProfileSetupScreen` (Save Name/Role).
        *   If Document Exists -> Check `familyId`.
            *   If No Family -> Show `FamilySetupScreen`.
            *   If Has Family -> Show `HomeScreen`.
2.  **Add Task**:
    *   User fills form -> `TaskProvider.addTask()` -> `FirestoreService.addTask()` -> Cloud.
3.  **Real-time Updates**:
    *   `HomeScreen` listens to `TaskProvider` -> `TaskProvider` listens to Firestore Stream.
    *   UI updates automatically when ANY family member changes a task.

## Verification Plan

### Automated Tests
*   We can write unit tests for `fromMap` and `toMap` model methods if we create data models.
*   Integration tests with Firebase Emulators (optional, but recommended if easy to set up).

### Manual Verification
1.  **Auth Flow**:
    *   Create a new account.
    *   Verify it appears in Firebase Console `Authentication`.
    *   Verify a `user` document is created in Firestore.
2.  **Family Flow**:
    *   User A creates a family "MyFamily".
    *   User B enters "MyFamily" join code.
    *   Verify both users are in `families.memberIds`.
3.  **Task Sync**:
    *   User A adds a task "Buy Milk".
    *   User B's screen should immediately show "Buy Milk" (via Stream).
    *   User B marks it "Done".
    *   User A's screen should update to "Done".
4.  **Photo Upload**:
    *   Upload a photo proof.
    *   Verify image appears in Firebase Storage.
    *   Verify `photoProofUrl` is set in Task document.

