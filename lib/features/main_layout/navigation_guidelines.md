# Cross-Tab Navigation Guidelines

This document explains how to implement navigation between different sections of the app (tabs) efficiently and while maintaining Clean Architecture principles.

## 1. Triggering a Tab Change

To switch to a different tab from any screen (e.g., from `HomeScreen` to `WorkoutsScreen`), use the `MainLayoutCubit`.

```dart
// Example: Navigating to Workouts tab (Index 2)
context.read<MainLayoutCubit>().changeTab(2);
```

## 2. Sharing Data Between Tabs

Do **NOT** use the `MainLayoutCubit` to pass data between tabs. The `MainLayoutCubit` should only be responsible for managing which tab is currently active.

If you need to navigate to a tab and have it perform a specific action (like selecting a category or filtering data), follow these steps:

1.  **Update the Feature Cubit**: Directly call a method on the Cubit responsible for that feature to update its state.
2.  **Change the Tab**: Call `changeTab` on the `MainLayoutCubit`.

### Example: Navigating to Workouts with a Category

```dart
// In HomeScreen or any other component:

// 1. Update WorkoutsCubit first (assuming it's provided high enough in the tree)
context.read<WorkoutsCubit>().selectCategory('chest');

// 2. Then switch the tab
context.read<MainLayoutCubit>().changeTab(2); // Workouts Index
```

## 3. Performance Best Practices

- **IndexedStack**: We use `IndexedStack` in `MainLayoutScreen` to keep the state of all tabs alive. This prevents screens from rebuilding from scratch every time you switch tabs.
- **BlocListener vs BlocBuilder**: Use `BlocListener` for navigation-related side effects. Only use `BlocBuilder` if the UI of the tab itself needs to change based on the `MainLayoutState` (which currently only contains `currentIndex`).
- **Clean Architecture**: 
    - The `MainLayoutCubit` acts as a "Navigator/Coordinator" for the main shell.
    - Each feature remains independent and manages its own business logic.
    - Avoid "Junk Drawer" states where a single Cubit holds unrelated data for multiple features.
