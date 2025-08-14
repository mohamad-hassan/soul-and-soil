import React, { useState, useEffect } from 'react';
import { categoriesSelector, categoryLimit, totalCates } from '../store/reducers/CategoriesReducer';
import { useSelector } from 'react-redux';
import { setCateOffset, translate } from '@/utils/helpers';

const CategoryTabContent = ({
  selectedCategoryIds,
  setSelectedCategoryIds,
  selectedCategories,
  setSelectedCategories,
  offset
}) => {

  const categories = useSelector(categoriesSelector);
  const cateLimit = useSelector(categoryLimit);
  const totalCategories = useSelector(totalCates);

  // Array of categories
  const allCategories = categories;

  // Update the comma-separated string whenever selections change
  useEffect(() => {
    // console.log('offset', offset);
    if (offset < 1) {
      const selectedNames = Object.keys(selectedCategories)
        .filter(category => selectedCategories[category])
        .join(", ");
      setSelectedCategoryIds(selectedNames);
    }
  }, [selectedCategories, setSelectedCategoryIds, offset]);

  // Split categories into two halves
  const halfLength = Math.ceil(allCategories.length / 2);
  const leftCategories = allCategories.slice(0, halfLength);
  const rightCategories = allCategories.slice(halfLength);

  // Handle selection/deselection
  const handleCategoryToggle = (category) => {
    setSelectedCategories(prev => ({
      ...prev,
      [category]: !prev[category]
    }));
  };

  useEffect(() => {
  }, [categories, cateLimit, totalCategories]);

  // Render a single category item
  const renderCategoryItem = (category, isLeftColumn = true) => (
    <div
      key={category?.id}
      className="flex items-center justify-between py-2 cursor-pointer"
      onClick={() => handleCategoryToggle(category?.id)}
    >
      <span className="text-gray-800 font-medium break-all">{category?.category_name}</span>
      <div className={`h-6 w-6 border border-gray-300 rounded flex items-center justify-center ${selectedCategories[category?.id] ? 'primaryBg' : 'bg-white'}`}>
        {selectedCategories[category?.id] && (
          <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 text-white" viewBox="0 0 20 20" fill="currentColor">
            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
          </svg>
        )}
      </div>
    </div>
  );

  return (
    categories?.length > 0 ?
      <div className="bg-white rounded-[8px] border borderColor p-2 sm:p-4 h-[300px] overflow-y-auto sm:h-max">
        <div className="flex">
          {/* Left Column */}
          <div className="flex-1 ltr:border-r rtl:border-l borderColor rtl:pl-4 ltr:pr-4">
            {leftCategories.map(category => renderCategoryItem(category))}
          </div>

          {/* Right Column */}
          <div className="flex-1 ltr:pl-4 rtl:pr-4">
            {rightCategories.map(category => renderCategoryItem(category, false))}
          </div>
        </div>

        {
          totalCategories > cateLimit && totalCategories !== categories?.length &&
          <div className='flexCenter gap-2 mt-8'>
            <button className='commonBtn !text-sm' onClick={() => setCateOffset(1)}>{translate('loadMore')}</button>
          </div>
        }

        {/* Display selected categories */}
        {/* <div className="mt-4 pt-3 border-t borderColor">
        <p className="text-sm text-gray-700">
          <span className="font-medium">Selected categories:</span> {selectedCategoryIds || "None"}
        </p>
      </div> */}
      </div>
      :
      <div className='text-[#1B2D51] flexCenter h-[250px] overflow-hidden font-[600] text-lg'>
        {translate('nodatafound')}
      </div>
  );
};

export default CategoryTabContent;