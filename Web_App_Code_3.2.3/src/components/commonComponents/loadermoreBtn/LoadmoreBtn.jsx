'use client'
import React, { useState } from 'react'
import LoadMoreSpinner from './LoaderSpinner'
import { translate } from '@/utils/helpers'

const LoadMoreBtn = ({ handleLoadMore, loadMoreLoading, searchModal }) => {

    return (
        <div className='mt-2 flexCenter w-full'>
            {
                loadMoreLoading ? <LoadMoreSpinner /> :
                    <button onClick={handleLoadMore} className={`loadMoreBtn commonBtn ${searchModal ? 'text-sm' : ''}`}>{translate('loadMore')}</button>
            }
        </div>
    )
}

export default LoadMoreBtn
