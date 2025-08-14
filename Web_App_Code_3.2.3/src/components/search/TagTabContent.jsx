import React, { useEffect } from 'react';
import { currentLangCode, translate } from '@/utils/helpers';
import LoadMoreBtn from '../commonComponents/loadermoreBtn/LoadmoreBtn';
import Skeleton from 'react-loading-skeleton';

const TagTabContent = ({
  selectedTagIds,
  setSelectedTagIds,
  selectedTags,
  setSelectedTags,
  tagsData,
  isLoadingTags,
  totalTags,
  handleLoadMoreTags,
  offset
}) => {
  const currLangCode = currentLangCode();

  // Array of tags
  const allTags = tagsData;

  // Split tags into two halves
  const halfLength = Math.ceil(allTags?.length / 2);
  const leftTags = allTags?.slice(0, halfLength);
  const rightTags = allTags?.slice(halfLength);

  useEffect(() => {
    // console.log(' offset=', offset);
    if (offset < 1) {
      const selectedNames = Object.keys(selectedTags)
        .filter(tag => selectedTags[tag])
        .join(", ");
      setSelectedTagIds(selectedNames);
    }
  }, [selectedTags, offset]);

  // Handle selection/deselection
  const handleTagToggle = (tag) => {
    setSelectedTags(prev => ({
      ...prev,
      [tag]: !prev[tag]
    }));
  };

  // Render a single tag item
  const renderTagItem = (tag, isLeftColumn = true) => (
    <div
      key={tag}
      className="flex items-center justify-between py-2 cursor-pointer"
      onClick={() => handleTagToggle(tag?.id)}
    >
      <span className="text-gray-800 font-medium break-all">{tag?.tag_name}</span>
      <div className={`h-6 w-6 border borderColor rounded flex items-center justify-center ${selectedTags[tag?.id] ? 'primaryBg' : 'bg-white'}`}>
        {selectedTags[tag?.id] && (
          <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 text-white" viewBox="0 0 20 20" fill="currentColor">
            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
          </svg>
        )}
      </div>
    </div>
  );

  return (
    allTags?.length > 0 ?
      <div className="bg-white rounded-[8px] border borderColor p-2 sm:p-4 h-[300px] overflow-y-auto sm:h-max">
        {
          isLoadingTags?.loading ?
            <div className="flex">
              {/* Left Column */}
              <div className="flex-1 ltr:border-r rtl:border-l borderColor rtl:pl-4 ltr:pr-4">
                {Array(7).fill().map((_, index) => (
                  <div
                    key={index}
                    className="flex items-center justify-between py-2"
                  >
                    <Skeleton width={100} height={20} className="h-4 w-24 bg-gray-300 rounded"></Skeleton>
                    <Skeleton width={20} height={20} className="h-6 w-6 bg-gray-300 rounded"></Skeleton>
                  </div>
                ))}
              </div>

              {/* Right Column */}
              <div className="flex-1 pl-4">
                {Array(7).fill().map((_, index) => (
                  <div
                    key={index}
                    className="flex items-center justify-between py-2"
                  >
                    <Skeleton width={100} height={20} className="h-4 w-24 bg-gray-300 rounded"></Skeleton>
                    <Skeleton width={20} height={20} className="h-6 w-6 bg-gray-300 rounded"></Skeleton>
                  </div>
                ))}
              </div>
            </div>
            :
            <div className="flex">
              {/* Left Column */}
              <div className="flex-1 ltr:border-r rtl:border-l borderColor rtl:pl-4 ltr:pr-4">
                {leftTags?.map(tag => renderTagItem(tag))}
              </div>

              {/* Right Column */}
              <div className="flex-1 ltr:pl-4 rtl:pr-4">
                {rightTags?.map(tag => renderTagItem(tag, false))}
              </div>
            </div>
        }

        {
          !isLoadingTags.loading && totalTags > 10 && totalTags !== tagsData?.length &&
          <div className='flexCenter gap-2 mt-8'>
            <LoadMoreBtn handleLoadMore={handleLoadMoreTags} loadMoreLoading={isLoadingTags.loadMoreLoading} searchModal={true} />
          </div>
        }

        {/* Display selected tags */}
        {/* <div className="mt-4 pt-3 border-t borderColor">
        <p className="text-sm text-gray-700">
          <span className="font-medium">Selected tags:</span> {selectedTagIds || "None"}
        </p>
      </div> */}
      </div>
      :
      <div className='text-[#1B2D51] flexCenter h-[250px] overflow-hidden font-[600] text-lg'>
        {translate('nodatafound')}
      </div>
  );
};

export default TagTabContent;