#ifndef RENDERDOC_H
#define RENDERDOC_H

#include <stdbool.h>

typedef struct _RenderDoc *RenderDoc;

RenderDoc renderDocCreate(char *path);
void renderDocDestroy(RenderDoc renderDoc);

void renderDocRenderFile(RenderDoc renderDoc, char *filename, bool forceNewLine);

void renderDocFinish(RenderDoc renderDoc);

#endif
