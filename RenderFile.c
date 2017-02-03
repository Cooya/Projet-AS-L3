#include "RenderFile.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "Error.h"
#include "SymbolsManager.h"

#define INDENT 32

extern FILE *yyout, *yyin;

extern int yyparse();

extern void flush_buffer();

struct _RenderFile {
    int lineCounter;
    int indentLevel;
    int blockCounter;
    int blocksToOpen, blocksToClose, blocksToCloseDrawEndBar, blocksToCloseWrapLine;

    bool scopeOpenedInLine;

    FILE *inputFile, *outputFile;

    ErrorManager errorManager;

    SymbolsManager symbolsManager;

    bool forceNewLine;
};



RenderFile renderFileCreate(FILE *inputFile, FILE *outputFile, ErrorManager errorManager, bool forceNewLine) {
    RenderFile renderFile = malloc(sizeof(struct _RenderFile));

    renderFile->lineCounter = 1;
    renderFile->indentLevel = 0;
    renderFile->blockCounter = 0;

    renderFile->blocksToOpen = 0;
    renderFile->blocksToClose = 0;
    renderFile->blocksToCloseDrawEndBar = 0;
    renderFile->blocksToCloseWrapLine = 0;

    renderFile->scopeOpenedInLine = false;

    renderFile->inputFile = inputFile;
    renderFile->outputFile = outputFile;

    renderFile->errorManager = errorManager;

    renderFile->symbolsManager = symbolsManagerCreate();

    renderFile->forceNewLine = forceNewLine;

    return renderFile;
}

void renderFileDestroy(RenderFile renderFile) {
    symbolsManagerDestroy(renderFile->symbolsManager);
    free(renderFile);
}


ErrorManager renderFileGetErrorManager(RenderFile renderFile) {
    return renderFile->errorManager;
}

SymbolsManager renderFileGetSymbolsManager(RenderFile renderFile) {
    return renderFile->symbolsManager;
}


int renderFileParse(RenderFile renderFile) {
    flush_buffer();
    yyin=renderFile->inputFile;
    yyout=renderFile->outputFile;
    return yyparse();
}



void writeHTML_Operator(RenderFile renderFile, char *op) {
	char *htmlOp;

	if(strcmp(op, "&") == 0)
		htmlOp = "&amp;";
	else
		htmlOp = op;

	fprintf(renderFile->outputFile, "<span class=\"syntaxOperator\">%s</span>", htmlOp);
}

void writeHTML_Identifier(RenderFile renderFile, char *identifier, int symbolId, bool declaration) {
	fprintf(renderFile->outputFile, "<a href=\"#symbol%d\" class=\"syntaxIdentifier symbol%d\" symbol=\"%d\"", symbolId, symbolId, symbolId);

	if(declaration)
        fprintf(renderFile->outputFile, " id=\"symbol%d\"", symbolId);

	fprintf(renderFile->outputFile, ">%s</a>", identifier);
}

void writeHTML_Special(RenderFile renderFile, char *word) {
	fprintf(renderFile->outputFile, "<span class=\"syntaxSpecialWord\">%s</span>", word);
}

void writeHTML_String(RenderFile renderFile, char *str) {
    fprintf(renderFile->outputFile, "<span class=\"syntaxString\">%s</span>", str);
}

void writeHTML_Constant(RenderFile renderFile, char *cst) {
    fprintf(renderFile->outputFile, "<span class=\"syntaxConstant\">%s</span>", cst);
}

void writeHTML_Space(RenderFile renderFile, char *spaces) {
    fprintf(renderFile->outputFile, "%s", spaces);
}

void writeHTML_NewLine(RenderFile renderFile, bool appearsInInput) {
    if(appearsInInput)
        renderFile->scopeOpenedInLine = false;

    if(renderFile->blocksToOpen > 0) { // On ne crée le bouton que du premier scope créé sur la ligne
        fprintf(renderFile->outputFile, "<div class=\"blockButton\" block=\"%d\" status=\"1\" style=\"left:%dpx;\"><div class=\"blockButtonText\">-</div></div>", renderFile->blockCounter, renderFile->indentLevel*INDENT);
        fprintf(renderFile->outputFile, "<span class=\"integratedInfo\" style=\"display:none;\" id=\"blockEllipsis%d\">...", renderFile->blockCounter);
        if(renderFile->forceNewLine)
            fprintf(renderFile->outputFile, "<span class=\"syntaxOperator\">}</span>");
        fprintf(renderFile->outputFile, "</span>");
    }

    for(int i=0; i<renderFile->indentLevel; i++) // On déssine les barres des scopes en cours avant cette ligne
        fprintf(renderFile->outputFile, "<div class=\"blockBar\" style=\"left:%dpx;\"></div>", i*INDENT);

    writeHTML_EndLine(renderFile);

    renderFile->indentLevel += renderFile->blocksToOpen;

    while(renderFile->blocksToOpen > 0) {
        fprintf(renderFile->outputFile, "<span id=\"block%d\">", renderFile->blockCounter++);
        renderFile->blocksToOpen--;
    }

    renderFile->indentLevel -= renderFile->blocksToClose;

    while(renderFile->blocksToClose > 0) {
        if(!renderFile->forceNewLine)
            fprintf(renderFile->outputFile, "</span>");
        else
            renderFile->blocksToCloseWrapLine++;
        renderFile->blocksToClose--;
    }

    writeHTML_BeginLine(renderFile, appearsInInput);

    while(renderFile->blocksToCloseDrawEndBar > 0) {
        fprintf(renderFile->outputFile, "<div class=\"blockBarEnd\" style=\"left:%dpx;\"></div>", (renderFile->indentLevel+renderFile->blocksToCloseDrawEndBar-1)*INDENT);
        renderFile->blocksToCloseDrawEndBar--;
    }
}

void writeHTML_BeginLine(RenderFile renderFile, bool appearsInInput) {
    fprintf(renderFile->outputFile, "<div class=\"lineWrapper\"><span class=\"lineCounter\">");
    if(appearsInInput)
        fprintf(renderFile->outputFile, "%4d", renderFile->lineCounter++);
    fprintf(renderFile->outputFile, "</span>");
    writeHTML_Indent(renderFile);
}

void writeHTML_EndLine(RenderFile renderFile) {
    fprintf(renderFile->outputFile, "</div>");

    while(renderFile->blocksToCloseWrapLine > 0) {
        fprintf(renderFile->outputFile, "</span>");
        renderFile->blocksToCloseWrapLine--;
    }
}

void writeHTML_Indent(RenderFile renderFile) {
    fprintf(renderFile->outputFile, "<span class=\"syntaxIndent\" style=\"width:%dpx;\"></span>", renderFile->indentLevel*INDENT);
}

void shiftIndent(RenderFile renderFile) {
    if(renderFile->scopeOpenedInLine && renderFile->forceNewLine)
        writeHTML_NewLine(renderFile, false);

    renderFile->blocksToOpen++;
    renderFile->scopeOpenedInLine = true;
}

void unshiftIndent(RenderFile renderFile, bool drawEndBar) {
    renderFile->blocksToClose++;
    if(drawEndBar || renderFile->forceNewLine)
        renderFile->blocksToCloseDrawEndBar++;

    if(!drawEndBar && renderFile->forceNewLine)
        writeHTML_NewLine(renderFile, false);
}
