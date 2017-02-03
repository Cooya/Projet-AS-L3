#ifndef SYMBOLSMANAGER_H
#define SYMBOLSMANAGER_H

typedef struct _SymbolsManager *SymbolsManager;

SymbolsManager symbolsManagerCreate();
void symbolsManagerDestroy(SymbolsManager symbolsManager);

void symbolsManagerPushScope(SymbolsManager symbolsManager);
void symbolsManagerPopScope(SymbolsManager symbolsManager);

int symbolsManagerAddSymbol(SymbolsManager symbolsManager, char *name);
int symbolsManagerGetSymbol(SymbolsManager symbolsManager, char *name);
int symbolsManagerGetSymbolInScope(SymbolsManager symbolsManager, char *name);

#endif
