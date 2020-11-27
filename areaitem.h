#ifndef AREAITEM_H
#define AREAITEM_H

#include <QObject>

enum class AreaItemType {
    Red = 0,
    Green,
    Blue,
    Yellow,
    Purple,
    Cyan,
    Count
};

class AreaItem
{

public:
    AreaItem();
    AreaItem(AreaItemType itemType);

    AreaItemType itemType() const { return m_itemType; }

    void setItemType(AreaItemType newType) { m_itemType = newType; }
private:
    AreaItemType m_itemType;
};

#endif // AREAITEM_H
