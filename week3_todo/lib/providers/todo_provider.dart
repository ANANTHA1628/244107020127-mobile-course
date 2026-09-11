import 'package:flutter_riverpod/flutter_riverpod.dart';


class Todo {
  Todo(this.title, {this.done = false});
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done);
}


class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => const [];

  void add(String title) => state = [...state, Todo(title)];

  void toggle(int index) {
    final todos = [...state];
    todos[index] = todos[index].copyWith(done: !todos[index].done);
    state = todos;
  }

  void remove(int index) => state = [...state]..removeAt(index);
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);


enum TodoFilter { all, uncompleted, completed }

class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void setFilter(TodoFilter filter) => state = filter;
}

final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);


final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  return switch (filter) {
    TodoFilter.uncompleted => todos.where((todo) => !todo.done).toList(),
    TodoFilter.completed => todos.where((todo) => todo.done).toList(),
    TodoFilter.all => todos,
  };
});