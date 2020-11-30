#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>

#include "gamearea.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("CraftplaceMS");
    app.setOrganizationDomain("craftplace.msgmail.com");
    app.setApplicationName("Match-3 Game");
    app.setWindowIcon(QIcon(":/images/res/red.png"));

    qmlRegisterType<GameArea>("Match3", 1, 0, "GameArea");

    GameArea area;

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("gameAreaModel", &area);
    engine.load(url);

    return app.exec();
}
