/*
   SPDX-License-Identifier: GPL-2.0-or-later
   SPDX-FileCopyrightText: 2024 Anders Lund <anders@alweb.dk>
*/

#include <QtGlobal>
#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#include "config-pumoku.h"

#if HAVE_KCRASH
#include <KCrash>
#endif

#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QUrl>

#include "version-pumoku.h"
#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#include "pumokuconfig.h"
 
using namespace Qt::Literals::StringLiterals;
 
#ifdef Q_OS_ANDROID
	Q_DECL_EXPORT
#endif

int main(int argc, char *argv[])
{
#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("org.kde.breeze"));
#else
    QApplication app(argc, argv);

    // Default to org.kde.desktop style unless the user forces another style
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(u"org.kde.desktop"_s);
    }
#endif

#ifdef Q_OS_WINDOWS
    if (AttachConsole(ATTACH_PARENT_PROCESS)) {
        freopen("CONOUT$", "w", stdout);
        freopen("CONOUT$", "w", stderr);
    } 
    QApplication::setStyle(QStringLiteral("breeze"));
    auto font = app.font();
    font.setPointSize(10);
    app.setFont(font);
#endif

    KLocalizedString::setApplicationDomain("pumoku");
    QCoreApplication::setOrganizationName(u"KDE"_s);

    KAboutData aboutData(
        // The program name used internally.
        u"pumoku"_s,
        // A displayable program name string.
        i18nc("@title", "PuMoKu"),
        // The program version string.
        QStringLiteral(PUMOKU_VERSION_STRING),
        // Short description of what the app does.
        i18n("PuMoKu is a classic sudoku game, developed for mobile."),
        // The license this code is released under.
        KAboutLicense::GPL,
        // Copyright Statement.
        i18n("(c) 2024"));
    aboutData.addAuthor(i18nc("@info:credit", "Anders Lund"), i18nc("@info:credit", "Maintainer"), u"anders@alweb.dk"_s);
    aboutData.setTranslator(i18nc("NAME OF TRANSLATORS", "Your names"), i18nc("EMAIL OF TRANSLATORS", "Your emails"));
    KAboutData::setApplicationData(aboutData);
#if HAVE_KCRASH
    KCrash::initialize();
#endif
    QGuiApplication::setWindowIcon(QIcon::fromTheme(u"org.kde.pumoku"_s));

    QQmlApplicationEngine engine;

    qmlRegisterSingletonInstance("org.kde.pumoku.private", 1, 0, "Config", PuMoKuConfig::self());
    QObject::connect(&app, &QCoreApplication::aboutToQuit, PuMoKuConfig::self(), &PuMoKuConfig::save);
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.loadFromModule("org.kde.pumoku", u"Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
