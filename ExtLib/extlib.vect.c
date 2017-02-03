#include "extlib.def.h"
#include "extlib.vect.h"
#include "extlib.vect.more.h"

#define DEFSIZE 8

struct _Vect {
    ElCmpFct cmpFct;
    int length;
    int size;
    int elemSize;
    Ptr ct;
};



static void vectResize(Vect);
static void vectShift(Vect, int, int);

static void vectResize(Vect vect) {
    vect->size*=2;
    vect->ct=realloc(vect->ct, vect->size*vect->elemSize);
}

static void vectShift(Vect vect, int base, int range) {
    if(range<0)
        for(int i=base; i<vect->length; i++)
            memcpy(vect->ct+i*vect->elemSize, vect->ct+(i+range)*vect->elemSize, vect->elemSize);
    else
        for(int i=vect->length-1; i<=base; i--)
            memcpy(vect->ct+i*vect->elemSize, vect->ct+(i+range)*vect->elemSize, vect->elemSize);
}



Vect vectNew(int elemSize) {
    Vect vect=malloc(sizeof(struct _Vect));

    if(elemSize<=0) {
        vect->elemSize=_elSizeFct(elemSize);
        vect->cmpFct=_elCompareFct(elemSize);
    }
    else {
        vect->elemSize=elemSize;
        vect->cmpFct=NULL;
    }

    vect->length=0;
    vect->size=DEFSIZE;
    vect->ct=malloc(DEFSIZE*vect->elemSize);
    return vect;
}

void vectDel(Vect vect) {
    free(vect->ct);
    free(vect);
}

Vect vectCopy(Vect vect) {
    Vect vect2=malloc(sizeof(struct _Vect));

    vect2->cmpFct=vect->cmpFct;
    vect2->length=vect->length;
    vect2->size=vect->size;
    vect2->elemSize=vect->elemSize;
    vect2->ct=malloc(vect2->size*vect2->elemSize);
    memcpy(vect2->ct, vect->ct, vect2->length*vect2->elemSize);

    return vect2;
}



Vect vectClear(Vect vect) {
    vect->length=0;
    return vect;
}



bool vectIsEmpty(Vect vect) {
    return vect->length==0;
}

int vectCount(Vect vect) {
    return vect->length;
}



Vect vectReshape(Vect vect) {
    if(vect->size>vect->length) {
        vect->size=vect->length;
        vect->ct=realloc(vect->ct, vect->size*vect->elemSize);
    }
    return vect;
}

Vect vectReshapeTo(Vect vect, int size) {
    vect->size = size;
    if(vect->length>size)
        vect->length=size;
    vect->ct=realloc(vect->ct, size*vect->elemSize);

    return vect;
}



Ptr vectGetFront_base(Vect vect) {
    return vect->ct;
}

Ptr vectGetBack_base(Vect vect) {
    return vect->ct+vect->elemSize*(vect->length-1);
}

Ptr vectGetAt_base(Vect vect, int pos) {
    return vect->ct+vect->elemSize*pos;
}



Vect vectSetFront_base(Vect vect, Ptr data) {
    memcpy(vect->ct, data, vect->elemSize);
    return vect;
}

Vect vectSetBack_base(Vect vect, Ptr data) {
    memcpy(vect->ct+vect->elemSize*(vect->length-1), data, vect->elemSize);
    return vect;
}

Vect vectSetAt_base(Vect vect, int pos, Ptr data) {
    memcpy(vect->ct+vect->elemSize*pos, data, vect->elemSize);
    return vect;
}

Vect vectSetAtF(Vect vect, int pos, Ptr data) {
    while(vect->size<=pos)
        vectResize(vect);
    memcpy(vect->ct+vect->elemSize*pos, data, vect->elemSize);
    if(vect->length<=pos)
        vect->length=pos+1;
    return vect;
}



Vect vectPushFront(Vect vect, Ptr data) {
    if(vect->length>=vect->size)
        vectResize(vect);

    vectShift(vect, 0, 1);

    memcpy(vect->ct, data, vect->elemSize);
    vect->length++;
    return vect;
}

Vect vectPushBack_base(Vect vect, Ptr data) {
    if(vect->length>=vect->size)
        vectResize(vect);

    memcpy(vect->ct+vect->elemSize*vect->length, data, vect->elemSize);
    vect->length++;
    return vect;
}

Vect vectPushAt(Vect vect, int pos, Ptr data) {
    if(pos>vect->length || pos<0)
        throwExc("ExtLib.Vect.vectPushAt", "Incorrect position, maybe makes the vector not contiguous.");
    if(vect->length>=vect->size)
        vectResize(vect);

    vectShift(vect, pos, 1);

    memcpy(vect->ct+vect->elemSize*pos, data, vect->elemSize);
    vect->length++;
    return vect;
}



Vect vectPopFront(Vect vect) {
    vectShift(vect, 0, -1);
    vect->length--;
    return vect;
}

Vect vectPopBack(Vect vect) {
    vect->length--;
    return vect;
}

Vect vectPopAt(Vect vect, int pos) {
    vectShift(vect, pos, -1);
    vect->length--;
    return vect;
}



Vect vectComparable(Vect vect, ElCmpFct fct) {
    vect->cmpFct=fct;
    return vect;
}

static int vectSortPartAsc(Ptr ct, int elemSize, ElCmpFct fct, int p, int r) {
    int i = p-1, j = r+1;
    while (1) {
        do
            j--;
        while (fct(ct+j*elemSize, ct+p*elemSize)>0);
        do
            i++;
        while (fct(ct+i*elemSize, ct+p*elemSize)<0);
        if (i < j) {
            Ptr temp=malloc(elemSize);
            memcpy(temp, ct+elemSize*i, elemSize);
            memcpy(ct+elemSize*i, ct+elemSize*j, elemSize);
            memcpy(ct+elemSize*j, temp, elemSize);
            free(temp);
        }
        else
            return j;
    }
}

static int vectSortPartDesc(Ptr ct, int elemSize, ElCmpFct fct, int p, int r) {
    int i = p-1, j = r+1;
    while (1) {
        do
            j--;
        while (fct(ct+j*elemSize, ct+p*elemSize)<0);
        do
            i++;
        while (fct(ct+i*elemSize, ct+p*elemSize)>0);
        if (i < j) {
            Ptr temp=malloc(elemSize);
            memcpy(temp, ct+elemSize*i, elemSize);
            memcpy(ct+elemSize*i, ct+elemSize*j, elemSize);
            memcpy(ct+elemSize*j, temp, elemSize);
            free(temp);
        }
        else
            return j;
    }
}

static void vectSortQS(Vect vect, int method, int p, int r) {
    int q;
    if (p < r) {
        if(method==EL_DESC)
            q = vectSortPartDesc(vect->ct, vect->elemSize, vect->cmpFct, p, r);
        else
            q = vectSortPartAsc(vect->ct, vect->elemSize, vect->cmpFct, p, r);
        vectSortQS(vect, method, p, q);
        vectSortQS(vect, method, q+1, r);
    }
}

Vect vectSort(Vect vect, int method) {
    if(vect->length>=2)
        vectSortQS(vect, method, 0, vect->length-1);
    return vect;
}



void vectHeap(Vect vect) {
    int elts=vectCount(vect);
    int effcost=elts*vect->elemSize;
    int opcost=sizeof(struct _Vect);
    int preallcost=(vect->size-elts)*vect->elemSize;

    printf("Vector at %p\n", vect);
    printf("\t%d elements, each using %d bytes\n", elts, vect->elemSize);
    printf("\t%d bytes used for elemets\n", effcost);
    printf("\t%d bytes used as operating cost\n", opcost);
    printf("\t%d bytes used as preallocated\n", preallcost);
    printf("\t%d bytes total used\n", effcost+opcost+preallcost);
}
