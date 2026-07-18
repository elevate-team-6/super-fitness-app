# Signup MVI Design Plan

This document outlines the architecture for the Signup flow using the **MVI (Model-View-Intent)** pattern with **Cubit**.

## 1. Register Intent (Events)
The UI will only interact with the Cubit through a single entry point `doIntent(RegisterIntent intent)`.

```dart
sealed class RegisterIntent {}

class UpdateAccountInfoIntent extends RegisterIntent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  UpdateAccountInfoIntent(this.firstName, this.lastName, this.email, this.password);
}

class SelectGenderIntent extends RegisterIntent {
  final String gender;
  SelectGenderIntent(this.gender);
}

class UpdateAgeIntent extends RegisterIntent {
  final int age;
  UpdateAgeIntent(this.age);
}

class UpdateWeightIntent extends RegisterIntent {
  final int weight;
  UpdateWeightIntent(this.weight);
}

class UpdateHeightIntent extends RegisterIntent {
  final int height;
  UpdateHeightIntent(this.height);
}

class SelectGoalIntent extends RegisterIntent {
  final String goal;
  SelectGoalIntent(this.goal);
}

class SelectActivityLevelIntent extends RegisterIntent {
  final String level;
  SelectActivityLevelIntent(this.level);
}

class NextStepIntent extends RegisterIntent {}
class PreviousStepIntent extends RegisterIntent {}
class SubmitSignupIntent extends RegisterIntent {}
```

---

## 2. Register State
The state will hold both the form data and the status of the signup operation using `BaseState`.

```dart
class RegisterState extends Equatable {
  // BaseState handles: isLoading, data (UserEntity), and errorMessage
  final BaseState<UserEntity> signupStatus;
  
  // Form Data
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String gender;
  final int age;
  final int weight;
  final int height;
  final String goal;
  final String activityLevel;
  
  // Navigation State
  final int currentStep; // 0 (Register) to 6 (Activity Level)

  const RegisterState({
    this.signupStatus = const BaseState(),
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.gender = '',
    this.age = 20,
    this.weight = 70,
    this.height = 170,
    this.goal = '',
    this.activityLevel = '',
    this.currentStep = 0,
  });

  RegisterState copyWith({
    BaseState<UserEntity>? signupStatus,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? gender,
    int? age,
    int? weight,
    int? height,
    String? goal,
    String? activityLevel,
    int? currentStep,
  }) {
    return RegisterState(
      signupStatus: signupStatus ?? this.signupStatus,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  @override
  List<Object?> get props => [
    signupStatus, firstName, lastName, email, password,
    gender, age, weight, height, goal, activityLevel, currentStep
  ];
}
```

---

## 3. Register Cubit (The View Model)
Inherits from `BaseCubit<RegisterState, BaseUiEvent>`.

- **`doIntent(RegisterIntent intent)`**: The only public method to handle UI actions.
- **Private methods**: `_onNextStep()`, `_onPreviousStep()`, `_onSubmit()`, etc.
- **UI Events**: Emits `NavigateEvent`, `ShowLoadingEvent`, etc., via `emitUiEvent()`.

### Submission Logic:
1. Emit `signupStatus` with `isLoading: true`.
2. Call `SignupUseCase.invoke(SignupRequest(...))`.
3. Handle `BaseResponse`:
   - If `Success`: Emit `signupStatus` with `data: UserEntity`, and `emitUiEvent(NavigateEvent(Home))`.
   - If `Error`: Emit `signupStatus` with `errorMessage: ...`, and `emitUiEvent(DisplayErrorEvent(...))`.

---

## 4. Navigation & UI Flow Strategy

The signup process is divided into two main screens to ensure a smooth user experience.

### Screen 1: Main Register Screen (Step 0)
- **Purpose:** Collect basic account credentials.
- **Fields:** First Name, Last Name, Email, Password.
- **Action:** Clicking "Register" triggers `UpdateAccountInfoEvent` followed by a navigation to Screen 2.

### Screen 2: Personalization Flow (Steps 1 to 6)
- **Purpose:** Collect fitness-related data for a personalized plan.
- **Implementation:** A single screen containing a dynamic view (e.g., `PageView` or conditional widgets) that reacts to `state.currentStep`.
- **Steps:**
    1. Gender Selection
    2. Age Selection
    3. Weight Input
    4. Height Input
    5. Goal Selection
    6. Activity Level Selection
- **Final Action:** Step 6 triggers `SubmitSignupEvent` which calls the `SignupUseCase`.

---

## 5. Implementation Details

- **Single Cubit Instance:** Both screens must share the same `RegisterCubit` instance to maintain form data integrity across the entire flow.
- **State Persistence:** Since all data is stored in a single `RegisterState`, navigating back and forth between steps (or even between the two screens) will preserve the user's input.
- **UI Events:**
    - `NavigateEvent`: Used to move from Screen 1 to Screen 2 when Step 0 is completed.
    - `ShowLoadingEvent` / `HideLoadingEvent`: Triggered during the final submission.
    - `DisplayErrorEvent`: Triggered if the validation fails or the API returns an error.

---

## 6. Logic Summary (Step Control)
- `currentStep = 0`: UI shows Account Form.
- `currentStep > 0`: UI shows Personalization Screen with relevant sub-view.
- `NextStepEvent`: Increments `currentStep` and handles transition logic.
- `PreviousStepEvent`: Decrements `currentStep` to allow corrections.
