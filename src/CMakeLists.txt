# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>

# Target: static library
qt_add_qml_module(pumoku_static
    STATIC
    URI org.kde.pumoku
    QML_FILES
        contents/ui/Main.qml
        contents/ui/GamePage.qml
        contents/ui/About.qml
        contents/ui/Settings.qml
        contents/ui/MainMenu.qml
        contents/ui/DigitButton.qml
        contents/ui/Import.qml
        contents/ui/PumokuEngine.qml
)

qt_add_resources(RESOURCES resources.qrc)

target_sources(pumoku_static PRIVATE
    qqwing.cpp
    qqw.cpp
)
target_sources(pumoku_static PUBLIC
    ${RESOURCES}
)
target_link_libraries(pumoku_static PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
    KF6::I18n
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
)
target_include_directories(pumoku_static PRIVATE ${CMAKE_BINARY_DIR})
target_compile_options (pumoku_static PUBLIC -fexceptions)
if (ANDROID)
    kirigami_package_breeze_icons(ICONS
        list-add
        help-about
        application-exit
        applications-graphics
    )
else()
    target_link_libraries(pumoku_static PUBLIC Qt::Widgets)
endif()

kconfig_add_kcfg_files(pumoku_static GENERATE_MOC pumokuconfig.kcfgc)

# Target: main executable
add_executable(pumoku main.cpp)
target_link_libraries(pumoku PRIVATE pumoku_static pumoku_staticplugin)
install(TARGETS pumoku ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
