#include "Logging.h"

#ifdef QZXING_TRACE
# define QZXING_LOG_SEVERITY QtDebugMsg
#else
# define QZXING_LOG_SEVERITY QtInfoMsg
#endif

Q_LOGGING_CATEGORY(qzxingLogger, "qzxing", QZXING_LOG_SEVERITY)
Q_LOGGING_CATEGORY(qzxingFilterLogger, "qzxing.filter", QZXING_LOG_SEVERITY)
