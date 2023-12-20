[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-718a45dd9cf7e7f842a935f5ebbe5719a5e09af4491e668f4dbf3b35d5cca122.svg)](https://classroom.github.com/online_ide?assignment_repo_id=13136296&assignment_repo_type=AssignmentRepo)
# Expense Tracker Application

## 1. Overview

This is a expense tracker application which also has a currency converter feature where we can get the live rate of any currency, we can make groups of specific categories or trips where we can add the expense incurred in these groups. It saves the data using a sqflite database model, where all the data gets stored locally. We can also add friends in the friends tab, and it displays the amount owed to a friend. The live rates of the currency gets fetched from a API from the web. If you have any questions please feel free to reach me out via mail at soham.sonar427@gmail.com or on linked at https://www.linkedin.com/in/sohamsonar23/, Thank You!

## 2. Features:

My application has the following high-level features:

1. There are at least 3 separate screens/pages in my application, each of which implemented as a separate widget. One of these pages is set to be the default "home" page that is displayed when the application is first launched. Navigation between pages are implemented using the standard Flutter mechanisms (e.g., `Navigator`, `TabBar`, `BottomNavigationBar`, etc.).
2. All of the pages in my application are backed by a stateful widget, which in turn is backed by a custom model class. This model class encapsulates the data that is displayed/manipulated on the page. I have choose these mechanisms (e.g., `setState`, `ChangeNotifier`, `Provider`, etc.) to update the UI on model object updates.
3. My app persists some user-updateable data across application launches in some way. Where I have used sqflite as a mechanism to do so, which stores all of the data in file locally.
4. My app also access some data from an external source (e.g., a RESTful API) and displays it in the app.


### 3 External packages

I have included the following packages in the `pubspec.yaml` file:

- [`collection`](https://pub.dev/packages/collection): a library that provides a set of additional data structures and utilities
- [`flutter_test`](https://pub.dev/packages/flutter_test): a library that provides a set of utilities for writing widget tests
- [`http`](https://pub.dev/packages/http): a library that provides a set of high-level asynchronous functions for communicating with HTTP servers
- [`mockito`](https://pub.dev/packages/mockito): a library that provides a set of utilities for mocking classes and objects
- [`path`](https://pub.dev/packages/path): a library that provides a set of utilities for manipulating paths
- [`path_provider`](https://pub.dev/packages/path_provider): a library that provides a set of utilities for locating files/directories on the filesystem
- [`provider`](https://pub.dev/packages/provider): a library that provides a set of utilities for managing and disseminating stateful data
- [`shared_preferences`](https://pub.dev/packages/shared_preferences): a library that provides a persistent store for simple data
- [`sqflite`](https://pub.dev/packages/sqflite): a library that wraps SQLite functionality for use in Flutter applications
- [`test`](https://pub.dev/packages/test): a library that provides a set of utilities for writing unit tests

