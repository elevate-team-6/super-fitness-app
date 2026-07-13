# Cross-Tab Navigation Guidelines

This document explains how to implement navigation between different sections of the app (tabs) efficiently and while maintaining Clean Architecture principles.

## 1. Triggering a Tab Change

To switch to a different tab from any screen (e.g., from `HomeScreen` to `WorkoutsScreen`), use the `MainLayoutCubit`.

```dart
// Example: Navigating to Workouts tab (Index 2)
context.read<MainLayoutCubit>().changeTab(2);
```

## 2. Passing Extra Data (e.g., Workout Category)

If you need to navigate to a tab and have it perform a specific action (like selecting a category), pass the data in the `extra` parameter.

```dart
// In HomeScreen:
context.read<MainLayoutCubit>().changeTab(
  2, // Workouts Index
  extra: {'category': 'chest'}, // Pass category ID or index
);
```

## 3. Handling Navigation in the Target Tab

The target screen (e.g., `WorkoutsScreen`) should use a `BlocListener` to react when the tab becomes active and check for any `extra` data.

```dart
// In WorkoutsScreen:
@override
Widget build(BuildContext context) {
  return BlocListener<MainLayoutCubit, MainLayoutState>(
    listenWhen: (previous, current) => 
        current.currentIndex == 2 && current.extra != null,
    listener: (context, state) {
      final category = state.extra['category'];
      // Trigger your WorkoutsCubit to filter or scroll
      // context.read<WorkoutsCubit>().filterByCategory(category);
      
      // IMPORTANT: Clear the extra data if it should only be handled once
      // context.read<MainLayoutCubit>().changeTab(2, extra: null);
    },
    child: ...
  );
}
```

## 4. Performance Best Practices

- **IndexedStack**: We use `IndexedStack` in `MainLayoutScreen` to keep the state of all tabs alive. This prevents screens from rebuilding from scratch every time you switch tabs.
- **BlocListener vs BlocBuilder**: Use `BlocListener` for navigation-related side effects. Only use `BlocBuilder` if the UI of the tab itself needs to change based on the `MainLayoutState`.
- **Clean Architecture**: 
    - The `MainLayoutCubit` acts as a "Coordinator".
    - Each feature remains independent.
    - Features communicate via the shared `MainLayoutCubit` without direct dependencies on each other's Blocs/Cubits.
