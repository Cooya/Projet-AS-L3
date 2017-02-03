/**
 * \file extlib.vect.h
 * \brief Primitives functions for vectors
 * \author Jason Pindat
 * \version 1.0
 * \date 05/21/2014
 *
 * All the basic functions to manage dynamic one-dimention arrays.
 *
 */

#ifndef EXTLIB_VECT_H
#define EXTLIB_VECT_H

#include "extlib.def.h"

/** Vect : type for a vector. */
typedef struct _Vect *Vect;



/** \brief Creates a new vector.
 *
 * \param elemSize : the size in bytes of each element of the vector. You can use the EL_* constants for the basic types, this will automatically link the comparison function too.
 * \return New empty vector.
 *
 */
Vect vectNew(int elemSize);
//#define vectNew2(elemSize) (*(type*)vectGetAt(vect, pos))

/** \brief Destroys a vector and all its content.
 *
 * \param vect : Vector to destroy.
 * \return void
 *
 */
void vectDel(Vect vect);

/** \brief Copies a vector and all its content.
 *
 * \param vect : Vector to copy.
 * \return Copy of the vector
 *
 */
Vect vectCopy(Vect vect);



/** \brief Removes the whole content of a vector.
 *
 * \param vect : Vector to clear.
 * \return The vector.
 *
 */
Vect vectClear(Vect vect);



/** \brief Tells whether a vector is empty or not
 *
 * \param vect : Vector to look in.
 * \return true if empty, false if not.
 *
 */
bool vectIsEmpty(Vect vect);

/** \brief Returns the size of the vector.
 *
 * \param vect : Vector to count elements.
 * \return Number of elements.
 *
 */
int vectCount(Vect vect);



/** \brief Returns the first element of a vector.
 *
 * \param vect : Vector to seek in.
 * \return Pointer to data.
 *
 */
Ptr vectGetFront_base(Vect vect);
#define vectGetFront(vect, type) (*(type*)vectGetFront_base(vect))

/** \brief Returns the last element of a vector.
 *
 * \param vect : Vector to seek in.
 * \return Pointer to data.
 *
 */
Ptr vectGetBack_base(Vect vect);
#define vectGetBack(vect, type) (*(type*)vectGetBack_base(vect))

/** \brief Returns the element at a given position in a vector.
 *
 * \param vect : Vector to seek in.
 * \param pos : Position of the element, 0 is start.
 * \return Pointer to data.
 *
 */
Ptr vectGetAt_base(Vect vect, int pos);
#define vectGetAt(vect, type, pos) (*(type*)vectGetAt_base(vect, pos))

/** \brief Sets the first element of a vector.
 *
 * \param vect : Vector to modify.
 * \param data : Pointer to the data.
 * \return The same vector.
 *
 */
Vect vectSetFront_base(Vect vect, Ptr data);
#define vectSetFront(vect, data) vectSetFront_base(vect, &(data))

/** \brief Sets the last element of a vector.
 *
 * \param vect : Vector to modify.
 * \param data : Pointer to the data.
 * \return The same vector.
 *
 */
Vect vectSetBack_base(Vect vect, Ptr data);
#define vectSetBack(vect, data) vectSetBack_base(vect, &(data))

/** \brief Sets the element at a given position in a vector.
 *
 * \param vect : Vector to modify.
 * \param pos : Position of the element, 0 is start.
 * \param data : Pointer to the data.
 * \return The same vector.
 *
 */
Vect vectSetAt_base(Vect vect, int pos, Ptr data);
#define vectSetAt(vect, pos, data) vectSetAt_base(vect, pos, &(data))


/** \brief Adds an element at the end of a vector.
 *
 * \param vect : Vector to add in.
 * \param data : Pointer to the data.
 * \return The same vector.
 *
 */
Vect vectPushBack_base(Vect vect, Ptr data);
#define vectPushBack(vect, data) vectPushBack_base(vect, &(data))



/** \brief Removes the element at the end of a vector.
 *
 * \param vect : Vector to remove in.
 * \return The same vector.
 *
 */
Vect vectPopBack(Vect vect);



/** \brief Details the heap usage of a given vector
 *
 * \param vect : Vector to seek in
 * \return void
 *
 */
void vectHeap(Vect vect);

#endif
