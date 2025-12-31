import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final ValueNotifier<bool> hasNewMessagesNotifier =
    ValueNotifier<bool>(false);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();