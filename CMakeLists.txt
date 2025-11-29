# SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.16)

project(pumoku VERSION 0.1)

include(FeatureSummary)

set(QT6_MIN_VERSION 6.5.0)
set(KF6_MIN_VERSION 6.0.0)

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

include(FeatureSummary)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(ECMFindQmlModule)
include(ECMAddAndroidApk)
if (NOT ANDROID)
    include(KDEGitCommitHooks)
    include(KDEClangFormat)
endif()

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX PUMOKU
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/src/version-pumoku.h"
)

set(QT_EXTRA_COMPONENTS)
if (NOT ANDROID)
    list(APPEND QT_EXTRA_COMPONENTS Widgets)
endif()

find_package(Qt6 ${QT6_MIN_VERSION} REQUIRED COMPONENTS Core Gui Qml QuickControls2 Svg ${QT_EXTRA_COMPONENTS})
find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS Kirigami2 CoreAddons Config I18n)

if (NOT ANDROID)
   find_package(KF6 ${KF_MIN_VERSION} OPTIONAL_COMPONENTS Crash)
endif()

qt_policy(SET QTP0001 NEW)

ecm_find_qmlmodule(org.kde.kirigamiaddons.formcard 1.0)

if (ANDROID)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android/version.gradle.in ${CMAKE_BINARY_DIR}/version.gradle)
endif()

if (TARGET KF6::Crash)
    set(HAVE_KCRASH TRUE)
endif()

KDE_ENABLE_EXCEPTIONS()
add_subdirectory(src)
add_subdirectory(icons)

install(FILES org.kde.pumoku.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.pumoku.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
ki18n_install(po)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

if (NOT ANDROID)
    file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES src/*.cpp src/*.h)
    kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
    kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
endif()
