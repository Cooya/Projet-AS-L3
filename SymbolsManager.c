
#include "SymbolsManager.h"
#include "ExtLib/extlib.vect.h"
#include "uthash.h"

struct _SymbolsManager {
    Vect scopes;
    int symbolIdCounter;
};

typedef struct _Symbols *Symbols;

struct _Symbols {
    int id;            /* we'll use this field as the key */
    char name[32];
    UT_hash_handle hh; /* makes this structure hashable */
};


SymbolsManager symbolsManagerCreate() {
    SymbolsManager symbolsManager = malloc(sizeof(struct _SymbolsManager));

    symbolsManager->scopes = vectNew(sizeof(Symbols));
    symbolsManager->symbolIdCounter = 0;

    symbolsManagerPushScope(symbolsManager); // Global scope

    return symbolsManager;
}

void symbolsManagerDestroy(SymbolsManager symbolsManager) {
    while(vectCount(symbolsManager->scopes) > 0)
        symbolsManagerPopScope(symbolsManager);

    vectDel(symbolsManager->scopes);
    free(symbolsManager);
}


void symbolsManagerPushScope(SymbolsManager symbolsManager) {
    Symbols symbols = NULL;
    vectPushBack(symbolsManager->scopes, symbols);
}

void symbolsManagerPopScope(SymbolsManager symbolsManager) {
    Symbols s, tmp;

    HASH_ITER(hh, vectGetBack(symbolsManager->scopes, Symbols), s, tmp) {
        HASH_DEL(vectGetBack(symbolsManager->scopes, Symbols), s);
        free(s);
    }

    vectPopBack(symbolsManager->scopes);
}

int symbolsManagerAddSymbol(SymbolsManager symbolsManager, char *name) {
    Symbols s = malloc(sizeof(struct _Symbols));

	s->id = symbolsManager->symbolIdCounter++;
	strcpy(s->name, name);

	HASH_ADD_STR(vectGetBack(symbolsManager->scopes, Symbols), name, s);

	return s->id;
}

int symbolsManagerGetSymbol(SymbolsManager symbolsManager, char *name) {
	Symbols s;

    for(int i=vectCount(symbolsManager->scopes)-1; i>=0; i--) {
        HASH_FIND_STR(vectGetAt(symbolsManager->scopes, Symbols, i), name, s);

        if(s)
            return s->id;
    }

	return -1;
}

int symbolsManagerGetSymbolInScope(SymbolsManager symbolsManager, char *name) {
	Symbols s;

    HASH_FIND_STR(vectGetBack(symbolsManager->scopes, Symbols), name, s);

    if(s)
        return s->id;

	return -1;
}
