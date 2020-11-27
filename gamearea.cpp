#include "gamearea.h"

#include <QFile>
#include <QRandomGenerator>
#include <QTextStream>

GameArea::GameArea(QObject *parent) : QObject(parent) { }

GameArea::~GameArea() {
    if (m_areaItems != nullptr)
        delete m_areaItems;
}

unsigned int GameArea::getItemIndex(unsigned int column, unsigned int row)
{
    if (column < m_dimension && row < m_dimension) {
        return column * m_dimension + row;
    }
    return 0;
}

std::tuple<unsigned int, unsigned int> GameArea::getItemCoords(unsigned int index)
{
    if (index >= m_dimension * m_dimension)
        return std::make_tuple(0, 0);
    return std::make_tuple(index / m_dimension, index % m_dimension);
}

void GameArea::resetArea()
{
    bool isAreaReady = false;
    if (m_areaItems != nullptr)
        delete m_areaItems;
    m_areaItems = new std::vector<AreaItem>(m_dimension * m_dimension);

    while (!isAreaReady) {
        std::generate(m_areaItems->begin(), m_areaItems->end(), []() {
            return AreaItem(static_cast<AreaItemType>(
                QRandomGenerator::global()->bounded(0, static_cast<int>(AreaItemType::Count))));
        });
        resolveMatches();
        isAreaReady = checkMoveIsAvailable();
    }
    m_score = 0;
    emit scoreChanged();
}

QVariantList GameArea::trySwapItems(int indexFrom, int indexTo)
{
    QVariantList emptyResult;
    if (!canItemSwaps(indexFrom, indexTo))
        return emptyResult;

    auto it1 = std::next(m_areaItems->begin(), indexFrom);
    auto it2 = std::next(m_areaItems->begin(), indexTo);
    std::swap(*it1, *it2);
    auto matchResult = findMatches();

    if (matchResult.size() != 0) {
        return resolveMatches();
    }

    std::swap(*it1, *it2);
    return emptyResult;
}

bool GameArea::canItemSwaps(int indexFrom, int indexTo)
{
    auto [col1, row1] = getItemCoords(static_cast<unsigned int>(indexFrom));
    auto [col2, row2] = getItemCoords(static_cast<unsigned int>(indexTo));
    unsigned int diffCol = (col1 > col2) ? (col1 - col2) : (col2 - col1);
    unsigned int diffRow = (row1 > row2) ? (row1 - row2) : (row2 - row1);
    return ((diffCol + diffRow) == 1);
}

void GameArea::setDimension(const unsigned int dimension)
{
    if (dimension > 3 && dimension <= 10) {
        if (m_dimension != dimension) {
            m_dimension = dimension;
            resetArea();
            emit dimensionChanged();
        }
    }
}

QString GameArea::getItemType(int index) {
    if(static_cast<unsigned int>(index) > m_dimension * m_dimension) return QString("");
    return m_itemColors.at(m_areaItems->at(static_cast<unsigned int>(index)).itemType());
}

GameArea::ItemsLine GameArea::findMatches()
{
    ItemsLine result;

    for (unsigned int i = 0; i < m_dimension; i++) {
        unsigned int sequenceLength = 1;
        for (unsigned int j = 0; j < m_dimension; j++) {
            if (j < m_dimension - 1
                && m_areaItems->at(getItemIndex(i, j)).itemType()
                       == m_areaItems->at(getItemIndex(i, j + 1)).itemType()) {
                sequenceLength++;
            } else {
                if (sequenceLength >= m_sizeToMatch) {
                    result.push_back(std::make_tuple(i, j - (sequenceLength - 1), j, false));
                }
                sequenceLength = 1;
            }
        }
    }

    for (unsigned int j = 0; j < m_dimension; j++) {
        unsigned int sequenceLength = 1;
        for (unsigned int i = 0; i < m_dimension; i++) {
            if (i < m_dimension - 1
                && m_areaItems->at(getItemIndex(i, j)).itemType()
                       == m_areaItems->at(getItemIndex(i + 1, j)).itemType()) {
                sequenceLength++;
            } else {
                if (sequenceLength >= m_sizeToMatch) {
                    result.push_back(std::make_tuple(j, i - (sequenceLength - 1), i, true));
                }
                sequenceLength = 1;
            }
        }
    }

    return result;
}

bool GameArea::checkMoveIsAvailable()
{
    for (unsigned int i = 0; i < m_dimension; i++) {
        for (unsigned int j = 0; j < m_dimension - 1; j++) {
            auto it1 = std::next(m_areaItems->begin(), getItemIndex(i, j));
            auto it2 = std::next(m_areaItems->begin(), getItemIndex(i, j + 1));
            std::swap(*it1, *it2);
            auto matchResult = findMatches();
            std::swap(*it1, *it2);
            if (matchResult.size() != 0)
                return true;
        }
    }

    for (unsigned int j = 0; j < m_dimension; j++) {
        for (unsigned int i = 0; i < m_dimension - 1; i++) {
            auto it1 = std::next(m_areaItems->begin(), getItemIndex(i, j));
            auto it2 = std::next(m_areaItems->begin(), getItemIndex(i + 1, j));
            std::swap(*it1, *it2);
            auto matchResult = findMatches();
            std::swap(*it1, *it2);
            if (matchResult.size() != 0)
                return true;
        }
    }

    return false;
}

QVariantList GameArea::removeItems(ItemsLine linesToRemove)
{
    QVariantList result;
    for (const auto &[x, y1, y2, isHorizontal] : linesToRemove) {
        for (unsigned int i = y1; i <= y2; i++) {
            unsigned int columnIndex = isHorizontal ? i : x;
            unsigned int rowIndex = isHorizontal ? x : i;
            if (m_areaItems->at(getItemIndex(columnIndex, rowIndex)).itemType()
                != AreaItemType::Count) {
                m_areaItems->at(getItemIndex(columnIndex, rowIndex)).setItemType(AreaItemType::Count);
                result.append("remove");
                result.append(getItemIndex(columnIndex, rowIndex));
                result.append(0);
            }
        }
    }
    return result;
}

QVariantList GameArea::dropItems()
{
    QVariantList result;
    for (unsigned int i = 0; i < m_dimension; i++) {
        for (unsigned int j = m_dimension - 1; j > 0; j--) {
            auto it1 = std::next(m_areaItems->begin(), getItemIndex(i, j));
            if ((*it1).itemType() == AreaItemType::Count) {
                for (unsigned int j1 = j; j1 > 0; j1--) {
                    auto it2 = std::next(m_areaItems->begin(), getItemIndex(i, j1 - 1));
                    if ((*it2).itemType() != AreaItemType::Count) {
                        std::swap(*it1, *it2);
                        result.append("move");
                        result.append(getItemIndex(i, j));
                        result.append(getItemIndex(i, j1 - 1));
                        break;
                    }
                }
            }
        }
    }
    return result;
}

QVariantList GameArea::respawnItems()
{
    QVariantList result;
    for (unsigned int i = 0; i < m_dimension; i++) {
        for (unsigned int j = 0; j < m_dimension; j++) {
            auto it1 = std::next(m_areaItems->begin(), getItemIndex(i, j));
            if ((*it1).itemType() == AreaItemType::Count) {
                (*it1).setItemType(static_cast<AreaItemType>(
                    QRandomGenerator::global()->bounded(0, static_cast<int>(AreaItemType::Count))));
                result.append("add");
                result.append(getItemIndex(i, j));
                result.append(m_itemColors.at((*it1).itemType()));
            }
        }
    }
    return result;
}

QVariantList GameArea::resolveMatches()
{
    unsigned int matchScore = 0;
    QVariantList result;
    bool matchExists = true;
    while (matchExists) {
        auto matches = findMatches();
        if (matches.size() == 0) {
            matchExists = false;
            break;
        }
        auto removedItems = removeItems(matches);
        if(static_cast<unsigned int>(removedItems.size() / 3) >= m_sizeToMatch) {
            matchScore += static_cast<unsigned int>(removedItems.size() / 3)
                          * (static_cast<unsigned int>(removedItems.size() / 3) - m_sizeToMatch + 1);
        }
        result.append(removedItems);
        result.append(dropItems());
        result.append(respawnItems());
    }
    if(matchScore > 0) {
        m_score += matchScore;
        emit scoreChanged();
    }
    //writeToFile("area.txt");
    return result;
}

void GameArea::writeToFile(QString filename)
{
    QFile file(filename);

    if (!file.open(QFile::WriteOnly | QFile::Truncate))
        return;

    QTextStream out(&file);
    for (unsigned int j = 0; j < m_dimension; j++) {
        for (unsigned int i = 0; i < m_dimension; i++) {
            out << m_itemColors.at(m_areaItems->at((getItemIndex(i, j))).itemType())[0];
        }
        out << '\n';
    }
    file.close();
}
