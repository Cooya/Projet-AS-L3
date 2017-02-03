#ifndef RENDERFILE_H
#define RENDERFILE_H

#include "SymbolsManager.h"
#include "Error.h"
#include <stdbool.h>
#include <stdio.h>

typedef struct _RenderFile *RenderFile;

RenderFile renderFileCreate(FILE *inputFile, FILE *outputFile, ErrorManager errorManager, bool forceNewLine);
void renderFileDestroy(RenderFile renderFile);

int renderFileParse(RenderFile renderFile);

void writeHTML_Identifier(RenderFile renderFile, char *identifier, int identifierId, bool declaration);
void writeHTML_Operator(RenderFile renderFile, char *op);
void writeHTML_Special(RenderFile renderFile, char *word);
void writeHTML_String(RenderFile renderFile, char *str);
void writeHTML_Constant(RenderFile renderFile, char *cst);
void writeHTML_Space(RenderFile renderFile, char *spaces);
void writeHTML_NewLine(RenderFile renderFile, bool appearsInInput);
void writeHTML_BeginLine(RenderFile renderFile, bool appearsInInput);
void writeHTML_EndLine(RenderFile renderFile);
void writeHTML_Indent(RenderFile renderFile);

void shiftIndent(RenderFile renderFile);
void unshiftIndent(RenderFile renderFile, bool drawEndBar);

SymbolsManager renderFileGetSymbolsManager(RenderFile renderFile);
ErrorManager renderFileGetErrorManager(RenderFile renderFile);

#endif
