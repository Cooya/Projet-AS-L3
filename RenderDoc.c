#include "RenderDoc.h"
#include "ExtLib/extlib.vect.h"
#include <stdbool.h>
#include "Error.h"
#include "RenderFile.h"

#ifdef _WIN32
#include <io.h>
#else
#include <sys/stat.h>
#include <sys/types.h>
#endif

#include "y.tab.h"
//extern FILE *yyin, *yyout;
extern int analyser(FILE *yyin, FILE * yyout);


RenderFile yyRenderFile;

struct _RenderDoc {
    Vect files;
    char path[256];
    ErrorManager errorManager;
};

typedef struct _RenderDocFile RenderDocFile;

struct _RenderDocFile {
    int id;
    bool valid;
    char *filename;
};

static int renderDocAddFile(RenderDoc renderDoc, char *sourceFileName);
static void renderDocValidateFile(RenderDoc renderDoc, int fileId);

static void renderDocRenderStructureFile(RenderDoc renderDoc, int fileId, FILE *inputFile, char *outputFileName);



RenderDoc renderDocCreate(char *path) {
    RenderDoc renderDoc = malloc(sizeof(struct _RenderDoc));

    renderDoc->files = vectNew(sizeof(RenderDocFile));

    renderDoc->errorManager = errorManagerCreate();

    strcpy(renderDoc->path, path);

    #ifdef _WIN32
    mkdir(renderDoc->path);
    #else
    mkdir(renderDoc->path, 0700);
    #endif

    errorManagerNotify(renderDoc->errorManager, "Beginning generation");
    errorManagerPushScope(renderDoc->errorManager);

    return renderDoc;
}

void renderDocDestroy(RenderDoc renderDoc) {
    errorManagerPopScope(renderDoc->errorManager);
    errorPrintSummary(renderDoc->errorManager);

    while(vectCount(renderDoc->files) > 0) {
        free(vectGetBack(renderDoc->files, RenderDocFile).filename);
        vectPopBack(renderDoc->files);
    }

    vectDel(renderDoc->files);

    errorManagerDestroy(renderDoc->errorManager);

    free(renderDoc);
}



int renderDocAddFile(RenderDoc renderDoc, char *sourceFileName) {
    RenderDocFile renderDocFile;

    renderDocFile.id = vectCount(renderDoc->files);
    renderDocFile.valid = false;
    renderDocFile.filename = malloc((strlen(sourceFileName)+1)*sizeof(char));
    strcpy(renderDocFile.filename, sourceFileName);

    vectPushBack(renderDoc->files, renderDocFile);

    return renderDocFile.id;
}

void renderDocValidateFile(RenderDoc renderDoc, int fileId) {
    RenderDocFile renderDocFile = vectGetAt(renderDoc->files, RenderDocFile, fileId);

    renderDocFile.valid = true;

    vectSetAt(renderDoc->files, fileId, renderDocFile);
}

void renderDocRenderFile(RenderDoc renderDoc, char *filename, bool forceNewLine) {
    FILE * sourceFile = fopen(filename, "r");

    errorManagerNotify(renderDoc->errorManager, "Rendering documentation of \"%s\"", filename);
    errorManagerAddFile(renderDoc->errorManager);
    errorManagerPushScope(renderDoc->errorManager);

    if(sourceFile) {
        char outputFileName[256];

        int fileId = renderDocAddFile(renderDoc, filename);

        sprintf(outputFileName, "%s/out%d.tmp", renderDoc->path, fileId);

        FILE * outputFile = fopen(outputFileName, "w");

        if(outputFile) {
            fprintf(outputFile, "<div class=\"codeContent\">");
            fprintf(outputFile, "<div class=\"lineCounterBar\"></div>");
            fprintf(outputFile, "<pre>");

            RenderFile renderFile = renderFileCreate(sourceFile, outputFile, renderDoc->errorManager, forceNewLine);

            yyRenderFile = renderFile;

            writeHTML_BeginLine(renderFile, true);

            if(renderFileParse(renderFile) == 0) {
                renderDocValidateFile(renderDoc, fileId);
                errorManagerNotify(renderDoc->errorManager, "Rendered successfully");
                errorManagerSetFileOk(renderDoc->errorManager);
            }
            else
                errorManagerRaise(renderDoc->errorManager, false, "unable to render documentation, a parsing error occurred");

            writeHTML_EndLine(renderFile);

            renderFileDestroy(renderFile);

            fprintf(outputFile, "</pre>");
            fprintf(outputFile, "</div>");

            fclose(outputFile);
        }
        else
            errorManagerRaise(renderDoc->errorManager, false, "unable to create output file \"%s\"", filename);

        fclose(sourceFile);
    }
    else
        errorManagerRaise(renderDoc->errorManager, false, "unable to open file \"%s\"", filename);

    errorManagerPopScope(renderDoc->errorManager);
}



void renderDocRenderStructureFile(RenderDoc renderDoc, int fileId, FILE *inputFile, char *outputFileName) {
    FILE * outputFile = fopen(outputFileName, "w");

    if(outputFile) {
        fprintf(outputFile, "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n");
        fprintf(outputFile, "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n");
        fprintf(outputFile, "<head>\n");
        fprintf(outputFile, "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>\n");
        fprintf(outputFile, "<link href=\"structureStyle.css\" rel=\"stylesheet\" type= \"text/css\" />\n");
        fprintf(outputFile, "<link href=\"codeStyle.css\" rel=\"stylesheet\" type= \"text/css\" />\n");
        fprintf(outputFile, "<script type=\"text/javascript\" src=\"jquery-2.1.1.min.js\"></script>\n");
        fprintf(outputFile, "<script type=\"text/javascript\" src=\"jquery.color.js\"></script>\n");
        fprintf(outputFile, "<script type=\"text/javascript\" src=\"dyn.js\"></script>\n");
        fprintf(outputFile, "<title>Doctet Documentation</title>\n");
        fprintf(outputFile, "</head>\n");

        fprintf(outputFile, "<body>\n");

        fprintf(outputFile, "<div id=\"leftPanel\">\n");

        for(int i=0; i<vectCount(renderDoc->files); i++) {
            RenderDocFile renderDocFile = vectGetAt(renderDoc->files, RenderDocFile, i);

            if(renderDocFile.valid)
                fprintf(outputFile, "<a href=\"out%d.html\" class=\"menuLink\">", renderDocFile.id);
            else
                fprintf(outputFile, "<span class=\"menuLinkInactive\">");

            fprintf(outputFile, "<div class=\"menuLinkBlock%s\">%s</div>", (i==fileId)?" menuLinkSelected":"", renderDocFile.filename);

            if(renderDocFile.valid)
                fprintf(outputFile, "</a>\n");
            else
                fprintf(outputFile, "</span>\n");
        }

        fprintf(outputFile, "</div>\n");

        fprintf(outputFile, "<div id=\"contentWrapper\">\n");

        int readSize;
        char buf[4096];
        while (readSize = fread(buf, 1, 4096, inputFile))
            fwrite(buf, 1, readSize, outputFile);

        fprintf(outputFile, "</div>\n");

        fprintf(outputFile, "</body>\n");
        fprintf(outputFile, "</html>\n");

        fclose(outputFile);
    }
    else
        errorManagerRaise(renderDoc->errorManager, true, "unable to create output file \"%s\"\n", outputFileName);
}

void renderDocFinish(RenderDoc renderDoc) {
    char inputFileName[256], outputFileName[256];
    FILE * inputFile;

    sprintf(inputFileName, "%s/indexContent.xml", renderDoc->path);

    inputFile = fopen(inputFileName, "r");

    if(inputFile) {
        sprintf(outputFileName, "%s/index.html", renderDoc->path);
        renderDocRenderStructureFile(renderDoc, -1, inputFile, outputFileName);

        fclose(inputFile);
    }
    else
        errorManagerRaise(renderDoc->errorManager, true, "unable to open file \"%s\"", inputFileName);

    for(int i=0; i<vectCount(renderDoc->files); i++) {
        RenderDocFile renderDocFile = vectGetAt(renderDoc->files, RenderDocFile, i);

        sprintf(inputFileName, "%s/out%d.tmp", renderDoc->path, renderDocFile.id);

        inputFile = fopen(inputFileName, "r");

        if(inputFile) {
            if(renderDocFile.valid) {
                sprintf(outputFileName, "%s/out%d.html", renderDoc->path, renderDocFile.id);
                renderDocRenderStructureFile(renderDoc, renderDocFile.id, inputFile, outputFileName);
            }

            fclose(inputFile);
            remove(inputFileName);
        }
        else
            errorManagerRaise(renderDoc->errorManager, true, "unable to open file \"%s\"", inputFileName);
    }
}
