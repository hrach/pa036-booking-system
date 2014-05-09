<?php

namespace PA032\Bundle\MultikinoBundle\VO;

class ProgramRecordVO
{
	/**
	 * 
	 * @var int
	 */
	public $projectionId;
	
	/**
	 * 
	 * @var string
	 */
	public $title;
	
	/**
	 * 
	 * @var string
	 */
	public $descritiption;
	
	/**
	 * 
	 * @var int
	 */
	public $runningTime;
	
	/**
	 * 
	 * @var int
	 */
	public $releaseYear;
	
	/**
	 * 
	 * @var \DateTime
	 */
	public $projectionStartTime;
	
	/**
	 * 
	 * @var real
	 */
	public $projectionPrice;
	
	/**
	 * 
	 * @var int
	 */
	public $hallId;
	
	/**
	 * 
	 * @var string[]
	 */
	public $genreTypes;
	
	/**
	 * 
	 * @var int
	 */
	public $seatsTotal;
	
	/**
	 * 
	 * @var int
	 */
	public $seatsBooked;
	
}

?>