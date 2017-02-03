#ifndef ERROR_H
#define ERROR_H

#include <stdarg.h>
#include <stdbool.h>

typedef struct _ErrorManager *ErrorManager;

ErrorManager errorManagerCreate();
void errorManagerDestroy(ErrorManager errorManager);

void errorManagerRaise(ErrorManager errorManager, bool fatal, const char* format, ...);
void errorManagerRaiseParsing(ErrorManager errorManager, int lineNumber, const char *format, ...);
void errorManagerVRaiseParsing(ErrorManager errorManager, int lineNumber, const char *format, va_list args);
void errorManagerNotify(ErrorManager errorManager, const char* format, ...);

void errorPrintSummary(ErrorManager errorManager);

void errorManagerPushScope(ErrorManager errorManager);
void errorManagerPopScope(ErrorManager errorManager);

void errorManagerAddFile(ErrorManager errorManager);
void errorManagerSetFileOk(ErrorManager errorManager);

#endif
