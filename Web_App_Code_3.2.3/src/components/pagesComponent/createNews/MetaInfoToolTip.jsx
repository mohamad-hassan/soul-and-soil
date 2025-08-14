'use client'
import React from 'react'
import {
    Tooltip,
    TooltipContent,
    TooltipProvider,
    TooltipTrigger,
  } from "@/components/ui/tooltip"
import { BsExclamationCircle } from "react-icons/bs"

const MetaInfoToolTip = ({info}) => {
  return (
    <div>
      <TooltipProvider>
      <Tooltip>
        <TooltipTrigger asChild>
          <span className="text-primary"><BsExclamationCircle /></span>
        </TooltipTrigger>
        <TooltipContent>
          <p>{info}</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
    </div>
  )
}

export default MetaInfoToolTip
