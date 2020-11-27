#ifndef GAMEAREA_H
#define GAMEAREA_H

#include <QObject>
#include <QList>
#include <QAbstractListModel>
#include <QVariantList>

#include "areaitem.h"

class GameArea : public QObject
{
    Q_OBJECT

    Q_PROPERTY(unsigned int dimension MEMBER m_dimension READ dimension WRITE setDimension NOTIFY dimensionChanged)
    Q_PROPERTY(unsigned int score MEMBER m_dimension READ score NOTIFY scoreChanged)
    using ItemsLine = std::vector<std::tuple<unsigned int, unsigned int, unsigned int, bool>>;


public:
    GameArea(QObject* parent = nullptr);
    ~GameArea();

    unsigned int dimension() const { return m_dimension; }
    void setDimension(const unsigned int dimension);

    unsigned int score() const { return m_score; }

    Q_INVOKABLE void resetArea();

    Q_INVOKABLE QString getItemType(int index);

    Q_INVOKABLE bool canItemSwaps(int indexFrom, int indexTo);

    Q_INVOKABLE QVariantList trySwapItems(int indexFrom, int indexTo);

    Q_INVOKABLE bool checkMoveIsAvailable();

    void writeToFile(QString filename);

signals:
    void dimensionChanged();
    void scoreChanged();

protected:
    unsigned int getItemIndex(unsigned int column, unsigned int row);
    std::tuple<unsigned int, unsigned int> getItemCoords(unsigned int index);

    ItemsLine findMatches();
    QVariantList removeItems(ItemsLine linesToRemove);
    QVariantList dropItems();
    QVariantList respawnItems();
    QVariantList resolveMatches();

private:
    std::map<AreaItemType, QString> m_itemColors = {
        {AreaItemType::Red, "red"},
        {AreaItemType::Green, "green"},
        {AreaItemType::Blue, "blue"},
        {AreaItemType::Yellow, "yellow"},
        {AreaItemType::Purple, "purple"},
        {AreaItemType::Cyan, "cyan"},
        {AreaItemType::Count, "transparent"}
    };
    std::vector<AreaItem>* m_areaItems = nullptr;
    unsigned int m_dimension = 0;
    unsigned int m_score = 0;
    const unsigned int m_sizeToMatch = 3;
};

#endif // GAMEAREA_H
