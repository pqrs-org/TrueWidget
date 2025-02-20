[![Build Status](https://github.com/pqrs-org/TrueWidget/workflows/TrueWidget%20CI/badge.svg)](https://github.com/pqrs-org/TrueWidget/actions)
[![License](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://github.com/pqrs-org/TrueWidget/blob/main/LICENSE.md)

# TrueWidget

TrueWidget displays macOS version, CPU usage and local time on screen at all times.

![screenshot](docs/screenshot.png)

The advantages of this application are as follows:

-   Check macOS version and host name at a glance when using multiple versions of macOS on your Mac.
-   The CPU usage can be monitored not only by instantaneous usage, which can vary widely, but also by a moving average, which is less likely to be blurred, to determine recent trends.
-   The local time can be displayed in a size that is easy to read unlike the time on the menu bar, which is not legible when using high resolution.

## Web pages

<https://truewidget.pqrs.org/>

## System requirements

macOS 13 Ventura or later

## How to build

System Requirements:

-   macOS 15.0+
-   Xcode 16.2+
-   Command Line Tools for Xcode
-   [XcodeGen](https://github.com/yonaskolb/XcodeGen)
-   [create-dmg](https://github.com/sindresorhus/create-dmg)

### Steps

1.  Get source code by executing a following command in Terminal.app.

    ```shell
    git clone --depth 1 https://github.com/pqrs-org/TrueWidget.git
    cd TrueWidget
    git submodule update --init --recursive --depth 1
    ```

2.  Find your codesign identity if you have one.<br />
    (Skip this step if you don't have your codesign identity.)

    ```shell
    security find-identity -p codesigning -v | grep 'Developer ID Application'
    ```

    The result is as follows.

    ```text
    1) 8D660191481C98F5C56630847A6C39D95C166F22 "Developer ID Application: Fumihiko Takayama (G43BCU2T37)"
    ```

    Your codesign identity is `8D660191481C98F5C56630847A6C39D95C166F22` in the above case.

3.  Set environment variable to use your codesign identity.<br />
    (Skip this step if you don't have your codesign identity.)

    ```shell
    export PQRS_ORG_CODE_SIGN_IDENTITY=8D660191481C98F5C56630847A6C39D95C166F22
    ```

4.  Build a package by executing a following command in Terminal.app.

    ```shell
    cd TrueWidget
    make clean all
    ```

    Then, TrueWidget-VERSION.dmg has been created in the current directory.
    It's a distributable package.

    Note: If you don't have codesign identity, the dmg works only on your machine.
