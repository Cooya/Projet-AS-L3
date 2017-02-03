/**
 * \file extlib.vect.more.h
 * \brief Primitives functions for vectors
 * \author Jason Pindat
 * \version 1.0
 * \date 05/21/2014
 *
 * All the basic functions to manage dynamic one-dimention arrays which have a non-constant complexity. Including this file includes the basic functions too.
 *
 */

#ifndef EXTLIB_VECT_MORE_H
#define EXTLIB_VECT_MORE_H

#include "extlib.def.h"
#include "extlib.vect.h"



/** \brief Makes the capacity of the array fit the data inside it while deleting alla the preallocated memory (Use just if necessary because of time intakes and few memory gains).
 *
 * \param vect : Vector to reshape.
 * \return The same vector.
 *
 */
Vect vectReshape(Vect vect);

/** \brief Sets the capacity of the array to size, crops the vector if size is smaller than its length.
 *
 * \param vect : Vector to reshape.
 * \return The same vector.
 *
 */
Vect vectReshapeTo(Vect vect, int size);



/** \brief Sets the element at a given position in a vector and forces creation if doesn't exists at any position.
 *
 * \param vect : Vector to modify.
 * \param pos : Position of the element, 0 is start.
 * \param data : Pointer to the data.
 * \return The same vector.
 *
 */
Vect vectSetAtF(Vect vect, int pos, Ptr data);
#define vectSetAtF2(vect, pos, data) vectSetAtF(vect, pos, &data)



/** \brief Adds an element at the begining of a vector (Not primitive).
 *
 * \param vect : Vector to add in.
 * \param data : Pointer to the data.
 * \return The same vector.
 *
 */
Vect vectPushFront(Vect vect, Ptr data);

/** \brief Adds an element at a given position in a vector (Not primitive).
 *
 * \param vect : Vector to add in.
 * \param pos : Position for the element, 0 is start.
 * \param data : Pointer to the data.
 * \return The same vector.
 *
 */
Vect vectPushAt(Vect vect, int pos, Ptr data);



/** \brief Removes the element at the begining of a vector (Not primitive).
 *
 * \param vect : Vector to remove in.
 * \return The same vector.
 *
 */
Vect vectPopFront(Vect vect);

/** \brief Removes the element at a given position in a vector (Not primitive).
 *
 * \param vect : Vector to remove in.
 * \param pos : Position of the element, 0 is start.
 * \return The same vector.
 *
 */
Vect vectPopAt(Vect vect, int pos);



/** \brief Sets the function to compare 2 elements of this vector, note that if you declared the vector with EL_*, the comparison function of the specified type is automatically linked.
 *
 * \param vect : Vector in which you set the fonction.
 * \param fct : pointer to the function, the function must take 2 pointers to the data and return an int which is <0 if 1st value is lower tha 2nd, >0 for the opposite and =0 if 1st value equals 2nd value.
 * \return The same vector.
 *
 */
Vect vectComparable(Vect vect, ElCmpFct fct);

/** \brief Sorts the vector with a quick sort, vectComparable must have been called or the vector must have been created with a EL_* constant.
 *
 * \param vect : Vector to sort.
 * \param method : must be EL_ASC or EL_DESC.
 * \return The same vector.
 *
 */
Vect vectSort(Vect vect, int method);

#endif
