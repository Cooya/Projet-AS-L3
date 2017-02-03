#include "Error.h"

#include <stdio.h>
#include <stdlib.h>

#define INDENT 3

struct _ErrorManager {
    int count, countParsing;
    int files, filesOk;
    bool fatalOccured;
    int scope;
};

static void errorManagerIndent(ErrorManager errorManager);


ErrorManager errorManagerCreate() {
    ErrorManager errorManager = malloc(sizeof(struct _ErrorManager));

    errorManager->count = 0;
    errorManager->countParsing = 0;

    errorManager->files = 0;
    errorManager->filesOk = 0;

    errorManager->fatalOccured = false;

    errorManager->scope = 0;

    return errorManager;
}

void errorManagerDestroy(ErrorManager errorManager) {
    free(errorManager);
}

void errorManagerIndent(ErrorManager errorManager) {
    for(int i=0; i<errorManager->scope*INDENT; i++)
        fprintf(stderr, " ");
}

void errorManagerRaise(ErrorManager errorManager, bool fatal, const char* format, ...) {
    errorManagerIndent(errorManager);

    fprintf(stderr, "Error : ");

    va_list argptr;
    va_start(argptr, format);
    vfprintf(stderr, format, argptr);
    va_end(argptr);

    fprintf(stderr, "\n");

    errorManager->count++;
    if(fatal)
        errorManager->fatalOccured = true;
}

void errorManagerRaiseParsing(ErrorManager errorManager, int lineNumber, const char *format, ...) {
    va_list argptr;
    va_start(argptr, format);
    errorManagerVRaiseParsing(errorManager, lineNumber, format, argptr);
    va_end(argptr);
}

void errorManagerVRaiseParsing(ErrorManager errorManager, int lineNumber, const char *format, va_list args) {
    errorManagerIndent(errorManager);

    fprintf(stderr, "Parsing Error at line %d : ", lineNumber);

    vfprintf(stderr, format, args);

    fprintf(stderr, "\n");

    errorManager->countParsing++;
}

void errorManagerNotify(ErrorManager errorManager, const char* format, ...) {
    errorManagerIndent(errorManager);

    va_list argptr;
    va_start(argptr, format);
    vfprintf(stderr, format, argptr);
    va_end(argptr);

    fprintf(stderr, "\n");
}

void errorPrintSummary(ErrorManager errorManager) {
    fprintf(stderr, "\n");

    errorManagerIndent(errorManager);
    fprintf(stderr, "Summary :\n");

    errorManagerPushScope(errorManager);

    if(errorManager->fatalOccured) {
        errorManagerIndent(errorManager);
        fprintf(stderr, "A fatal error occured and the documentation didn't render.\n");
    }
    else {
        errorManagerIndent(errorManager);
        if(errorManager->count==0)
            fprintf(stderr, "Documentation rendered successfully.\n");
        else
            fprintf(stderr, "Documentation rendered with %d error%s (%d parsing error%s).\n", errorManager->count, (errorManager->count!=1)?"s":"", errorManager->countParsing, (errorManager->countParsing!=1)?"s":"");

        errorManagerIndent(errorManager);
        fprintf(stderr, "%d/%d file%s documented.", errorManager->filesOk, errorManager->files, (errorManager->filesOk!=1)?"s":"");
    }

    errorManagerPopScope(errorManager);

    fprintf(stderr, "\n");
}

void errorManagerPushScope(ErrorManager errorManager) {
    errorManager->scope++;
}
void errorManagerPopScope(ErrorManager errorManager) {
    errorManager->scope--;
}

void errorManagerAddFile(ErrorManager errorManager) {
    errorManager->files++;
}
void errorManagerSetFileOk(ErrorManager errorManager) {
    errorManager->filesOk++;
}
