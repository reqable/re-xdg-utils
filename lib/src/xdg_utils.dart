// Copyright 2012 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// https://chromium.googlesource.com/chromium/src/+/refs/heads/main/base/nix/xdg_util.cc

import 'dart:io';

import './xdg_desktop_env.dart';

/// XDG refers to http://en.wikipedia.org/wiki/Freedesktop.org .
/// This file contains utilities found across free desktop environments.
class Xdg {

  /// Return an entry from the DesktopEnvironment enum with a best guess
  /// of which desktop environment we're using.  We use this to know when
  /// to attempt to use preferences from the desktop environment --
  /// proxy settings, password manager, etc.
  static DesktopEnvironment get desktopEnvironment {
    // XDG_CURRENT_DESKTOP is the newest standard circa 2012.
    final String? desktop = Platform.environment['XDG_CURRENT_DESKTOP'];
    if (desktop != null) {
      final Iterable<String> values = desktop.split(':').map((e) => e.trim()).where((e) => e.isNotEmpty);
      for (final String value in values) {
        if (value == 'Unity') {
          // gnome-fallback sessions set kXdgCurrentDesktopEnvVar to Unity
          // desktopSession can be gnome-fallback or gnome-fallback-compiz
          if (Platform.environment['desktopSession']?.contains('gnome-fallback') == true) {
            return DesktopEnvironment.gnom;
          }
          return DesktopEnvironment.unity;
        }
        if (value == 'Deepin') {
          return DesktopEnvironment.deepin;
        }
        if (value == 'GNOME') {
          return DesktopEnvironment.gnom;
        }
        if (value == 'X-Cinnamon') {
          return DesktopEnvironment.cinnamon;
        }
        if (value == 'KDE') {
          final String? version = Platform.environment['KDE_SESSION_VERSION'];
          if (version == '5') {
            return DesktopEnvironment.kde5;
          }
          if (version == '6') {
            return DesktopEnvironment.kde6;
          }
          return DesktopEnvironment.kde4;
        }
        if (value == 'Pantheon') {
          return DesktopEnvironment.pantheon;
        }
        if (value == 'XFCE') {
          return DesktopEnvironment.xfce;
        }
        if (value == 'UKUI') {
          return DesktopEnvironment.ukui;
        }
        if (value == 'LXQt') {
          return DesktopEnvironment.lxqt;
        }
      }
    }
    // desktopSession was what everyone used in 2010.
    final String? desktopSession = Platform.environment['DESKTOP_SESSION'];
    if (desktopSession != null) {
      if (desktopSession == 'deepin') {
        return DesktopEnvironment.deepin;
      }
      if (desktopSession == 'gnome' || desktopSession == 'mate') {
        return DesktopEnvironment.gnom;
      }
      if (desktopSession == 'kde4' || desktopSession == 'kde-plasma') {
        return DesktopEnvironment.kde4;
      }
      if (desktopSession == 'kde') {
        // This may mean KDE4 on newer systems, so we have to check.
        final String? version = Platform.environment['KDE_SESSION_VERSION'];
        if (version != null) {
          return DesktopEnvironment.kde4;
        }
        return DesktopEnvironment.kde3;
      }
      if (desktopSession.contains('xfce') || desktopSession == 'xubuntu') {
        return DesktopEnvironment.xfce;
      }
      if (desktopSession == 'ukui') {
        return DesktopEnvironment.ukui;
      }
    }
    // Fall back on some older environment variables.
    // Useful particularly in the DESKTOP_SESSION=default case.
    if (Platform.environment.keys.contains('GNOME_DESKTOP_SESSION_ID')) {
      return DesktopEnvironment.gnom;
    }
    if (Platform.environment.keys.contains('KDE_FULL_SESSION')) {
      if (Platform.environment.keys.contains('KDE_SESSION_VERSION')) {
        return DesktopEnvironment.kde4;
      }
      return DesktopEnvironment.kde3;
    }
    return DesktopEnvironment.other;
  }

}