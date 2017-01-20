#ifndef QZXING_LOGGING_H
#define QZXING_LOGGING_H

#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(qzxingLogger)
Q_DECLARE_LOGGING_CATEGORY(qzxingFilterLogger)

#define QZX_DEBUG    qCDebug(qzxingLogger)
#define QZX_INFO     qCInfo(qzxingLogger)
#define QZX_WARN     qCWarning(qzxingLogger)
#define QZX_CRITICAL qCCritical(qzxingLogger)

#define QZX_FILTER_DEBUG    qCDebug(qzxingFilterLogger)
#define QZX_FILTER_INFO     qCInfo(qzxingFilterLogger)
#define QZX_FILTER_WARN     qCWarning(qzxingFilterLogger)
#define QZX_FILTER_CRITICAL qCCritical(qzxingFilterLogger)

#endif // QZXING_LOGGING_H

