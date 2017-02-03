#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include "Error.h"
#include "RenderDoc.h"

void usage() {
    printf("Usage : \n");
}

int main(int argc, char *argv[]) {

    if(argc <= 1)
        usage();
    else {
        int option;

        bool forceNewLine = true;

        while((option = getopt (argc, argv, "h?l")) != -1) { // options suivies de : pour un argument et de :: pour un argument facultatif
            switch(option) {
                case 'h':
                case '?':
                    usage();
                    break;
                case 'l':
                    forceNewLine = false;
                    break;
                default:
                    fprintf(stderr, "Error : Option -%c does not exist\n", option);
                    usage();
                    break;
            }
        }

        RenderDoc renderDoc = renderDocCreate("doctet");

        while(optind < argc)
            renderDocRenderFile(renderDoc, argv[optind++], forceNewLine);

        renderDocFinish(renderDoc);

        renderDocDestroy(renderDoc);
    }

    return EXIT_SUCCESS;
}
