# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config-pumoku.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-pumoku.h)

# Target: static library
add_library(pumoku_static STATIC)
ecm_add_qml_module(pumoku_static
    URI org.kde.pumoku
    GENERATE_PLUGIN_SOURCE
    QML_FILES
        contents/ui/Main.qml
        contents/ui/GamePage.qml
        contents/ui/About.qml
        contents/ui/Settings.qml
        contents/ui/MainMenu.qml
        contents/ui/DigitButton.qml
        contents/ui/Import.qml
        contents/ui/PumokuEngine.qml
        contents/ui/PumokuListItem.qml
)

qt_add_resources(RESOURCES resources.qrc)

target_sources(
    pumoku_static
    PRIVATE
        qqwing.cpp
        qqwing.hpp
        qqw.cpp
        qqw.h
        filemanager.h
        filemanager.cpp
        gamesmodel.h
        gamesmodel.cpp
)
target_sources(pumoku_static PUBLIC ${RESOURCES})
target_link_libraries(
    pumoku_static
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Svg
        KF6::I18n
        KF6::I18nQml
        KF6::CoreAddons
        KF6::ConfigCore
        KF6::ConfigGui
)
target_include_directories(pumoku_static PRIVATE ${CMAKE_BINARY_DIR})
if(ANDROID)
    kirigami_package_breeze_icons(ICONS
        list-add
        help-about-symbolic
        application-exit
        applications-graphics
        document-share-symbolic
        application-menu-symbolic
        open-for-editing-symbolic
        flashlight-on-symbolic
        settings-configure-symbolic
        edit-undo-symbolic
        edit-redo-symbolic
        games-hint-symbolic
        open-for-editing-symbolic
        tool_eraser-symbolic
    )
else()
    target_link_libraries(pumoku_static PUBLIC Qt::Widgets)
endif()

kconfig_add_kcfg_files(pumoku_static GENERATE_MOC pumokuconfig.kcfgc)

# Target: main executable
add_executable(pumoku main.cpp)
target_link_libraries(
    pumoku
    PRIVATE
        pumoku_static
        pumoku_staticplugin
)
if(TARGET KF6::Crash)
    target_link_libraries(pumoku PRIVATE KF6::Crash)
endif()
install(
    TARGETS
        pumoku
        ${KDE_INSTALL_TARGETS_DEFAULT_ARGS}
)
ecm_add_android_apk(pumoku ANDROID_DIR ${CMAKE_SOURCE_DIR}/android)
