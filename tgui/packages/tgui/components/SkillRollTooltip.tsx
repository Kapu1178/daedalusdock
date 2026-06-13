import { BooleanLike } from 'tgui-core/react';

import { Flex } from './Flex';
import { Tooltip } from './Tooltip';

type Props = {
  chanceString: string;
  good: BooleanLike;
  skillName: string;
  text: string;
} & Omit<TooltipContentProps, 'classChaser'>;

export function SkillRollTooltip(props: Props) {
  const {
    chance,
    chanceString,
    dice,
    good,
    modifier,
    requirement,
    roll,
    skillName,
    text,
  } = props;

  const goodorbadClass = good ? 'good' : 'bad';
  return (
    <Flex direction="row">
      <span className={`RollTooltip__skillName--${goodorbadClass}`}>
        {`${skillName} `}
      </span>
      <Tooltip
        position="top"
        content={
          <TooltipContent
            chance={chance}
            classChaser={goodorbadClass}
            dice={dice}
            modifier={modifier}
            roll={roll}
            requirement={requirement}
          />
        }
      >
        <span className="RollTooltip__tooltip">{chanceString}</span>
      </Tooltip>
      <span className="RollTooltip__spacer">{': '}</span>
      <span className={`RollTooltip--${goodorbadClass}`}>{text}</span>
    </Flex>
  );
}

type TooltipContentProps = {
  chance: number;
  classChaser: string;
  dice: string;
  modifier: number;
  requirement: number;
  roll: number;
};

function TooltipContent(props: TooltipContentProps) {
  const { chance, classChaser, dice, modifier, roll, requirement } = props;
  const resultClassName = 'RollTooltip__result--' + classChaser;
  return (
    <div className="RollTooltip__floating">
      <div>
        {`${chance}% | Result: `}
        <span className={resultClassName}>{roll + (modifier || 0)}</span>
        {modifier !== 0 && (
          <span>
            {` (`}
            {
              <span className={resultClassName}>
                {modifier > 0 && '+'}
                {modifier}
              </span>
            }
            {')'}
          </span>
        )}
        <span>
          {' | Check: '}
          <span style={{ fontWeight: 'bold' }}>{requirement}</span>
        </span>
      </div>
      <Flex direction="row" justify="center" gap="8px" mt="4px">
        {dice.split('-').map((face, i) => (
          <DieSVG
            className={'RollTooltip__die--' + classChaser}
            face={parseInt(face, 10)}
            size={'48px'}
            key={i}
          />
        ))}
      </Flex>
    </div>
  );
}

type DiceSvgProps = {
  className: string;
  face: number;
  size?: string | number;
};

function DieSVG(props: DiceSvgProps) {
  const { face, size = '32px' } = props;

  const renderPips = () => {
    switch (face) {
      case 1:
        return (
          <>
            <rect className="die-bg" x="2" y="2" width="96" height="96" />
            <circle className="die-pip" cx="50" cy="50" />
          </>
        );
      case 2:
        return (
          <>
            <rect className="die-bg" x="2" y="2" width="96" height="96" />
            <circle className="die-pip" cx="26" cy="26" />
            <circle className="die-pip" cx="74" cy="74" />
          </>
        );
      case 3:
        return (
          <>
            <rect className="die-bg" x="2" y="2" width="96" height="96" />
            <circle className="die-pip" cx="26" cy="26" />
            <circle className="die-pip" cx="50" cy="50" />
            <circle className="die-pip" cx="74" cy="74" />
          </>
        );
      case 4:
        return (
          <>
            <rect className="die-bg" x="2" y="2" width="96" height="96" />
            <circle className="die-pip" cx="26" cy="26" />
            <circle className="die-pip" cx="74" cy="26" />
            <circle className="die-pip" cx="26" cy="74" />
            <circle className="die-pip" cx="74" cy="74" />
          </>
        );
      case 5:
        return (
          <>
            <rect className="die-bg" x="2" y="2" width="96" height="96" />
            <circle className="die-pip" cx="26" cy="26" />
            <circle className="die-pip" cx="74" cy="26" />
            <circle className="die-pip" cx="50" cy="50" />
            <circle className="die-pip" cx="26" cy="74" />
            <circle className="die-pip" cx="74" cy="74" />
          </>
        );
      case 6:
        return (
          <>
            <rect className="die-bg" x="2" y="2" width="96" height="96" />
            <circle className="die-pip" cx="26" cy="26" />
            <circle className="die-pip" cx="74" cy="26" />
            <circle className="die-pip" cx="26" cy="50" />
            <circle className="die-pip" cx="74" cy="50" />
            <circle className="die-pip" cx="26" cy="74" />
            <circle className="die-pip" cx="74" cy="74" />
          </>
        );
      default:
        return null;
    }
  };

  return (
    <svg
      className={props.className}
      viewBox="0 0 100 100"
      width={size}
      height={size}
    >
      <g>{renderPips()}</g>
    </svg>
  );
}
