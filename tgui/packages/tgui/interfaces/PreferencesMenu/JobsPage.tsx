import { sortBy } from 'common/collections';
import { classes } from 'common/react';
import { FC, ReactNode } from 'react';
import { Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Box, Button, Dropdown, Stack } from '../../components';
import { logger } from '../../logging';
import {
  createSetPreference,
  Job,
  JoblessRole,
  JobPriority,
  PreferencesMenuData,
} from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const sortJobs = (entries: [string, Job][], head?: string) =>
  sortBy<[string, Job]>(
    ([key, _]) => (key === head ? -1 : 1),
    ([key, _]) => key,
  )(entries);

const PRIORITY_BUTTON_SIZE = '18px';

const PriorityButton = (props: {
  color: string;
  enabled: boolean;
  modifier?: string;
  name: string;
  onClick: () => void;
}) => {
  const className = `PreferencesMenu__Jobs__departments__priority`;

  return (
    // PARIAH EDIT START
    <Button
      className={classes([
        className,
        props.modifier && `${className}--${props.modifier}`,
      ])}
      color={props.enabled ? props.color : 'white'}
      circular
      onClick={props.onClick}
      tooltip={props.name}
      tooltipPosition="bottom"
      height={PRIORITY_BUTTON_SIZE}
      width={PRIORITY_BUTTON_SIZE}
    />
    // PARIAH EDIT END
  );
};

type CreateSetPriority = (priority: JobPriority | null) => () => void;

const createSetPriorityCache: Record<string, CreateSetPriority> = {};

const createCreateSetPriorityFromName = (
  jobName: string,
): CreateSetPriority => {
  if (createSetPriorityCache[jobName] !== undefined) {
    return createSetPriorityCache[jobName];
  }

  const perPriorityCache: Map<JobPriority | null, () => void> = new Map();

  const createSetPriority = (priority: JobPriority | null) => {
    const existingCallback = perPriorityCache.get(priority);
    if (existingCallback !== undefined) {
      return existingCallback;
    }

    const setPriority = () => {
      const { act } = useBackend<PreferencesMenuData>();

      act('set_job_preference', {
        job: jobName,
        level: priority,
      });
    };

    perPriorityCache.set(priority, setPriority);
    return setPriority;
  };

  createSetPriorityCache[jobName] = createSetPriority;

  return createSetPriority;
};

const PriorityHeaders = () => {
  const className = 'PreferencesMenu__Jobs__PriorityHeader';

  return (
    <Stack>
      <Stack.Item grow />

      <Stack.Item className={className}>Off</Stack.Item>

      <Stack.Item className={className}>Low</Stack.Item>

      <Stack.Item className={className}>Medium</Stack.Item>

      <Stack.Item className={className}>High</Stack.Item>
    </Stack>
  );
};

const PriorityButtons = (props: {
  createSetPriority: CreateSetPriority;
  isOverflow: boolean;
  priority: JobPriority;
}) => {
  const { createSetPriority, isOverflow, priority } = props;

  return (
    <Box
      inline // PARIAH EDIT
      style={{
        alignItems: 'center',
        height: '100%',
        textAlign: 'end', // PARIAH EDIT
        padding: '0.3em', // PARIAH EDIT
      }}
    >
      {isOverflow ? (
        <>
          <PriorityButton
            name="Off"
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="On"
            color="green"
            enabled={!!priority}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      ) : (
        <>
          <PriorityButton
            name="Off"
            modifier="off"
            color="light-grey"
            enabled={!priority}
            onClick={createSetPriority(null)}
          />

          <PriorityButton
            name="Low"
            color="red"
            enabled={priority === JobPriority.Low}
            onClick={createSetPriority(JobPriority.Low)}
          />

          <PriorityButton
            name="Medium"
            color="yellow"
            enabled={priority === JobPriority.Medium}
            onClick={createSetPriority(JobPriority.Medium)}
          />

          <PriorityButton
            name="High"
            color="green"
            enabled={priority === JobPriority.High}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      )}
    </Box> // PARIAH EDIT
  );
};

const JobRow = (props: { className?: string; job: Job; name: string }) => {
  const { data } = useBackend<PreferencesMenuData>();
  const { className, job, name } = props;

  const isOverflow = data.overflow_role === name;
  const priority = data.job_preferences[name];

  const createSetPriority = createCreateSetPriorityFromName(name);
  // PARIAH EDIT
  const { act } = useBackend<PreferencesMenuData>();
  // PARIAH EDIT END

  const experienceNeeded =
    data.job_required_experience && data.job_required_experience[name];
  const daysLeft = data.job_days_left ? data.job_days_left[name] : 0;

  // PARIAH EDIT
  const alt_title_selected = data.job_alt_titles[name]
    ? data.job_alt_titles[name]
    : name;
  // PARIAH EDIT END

  let rightSide: ReactNode;

  if (experienceNeeded) {
    const { experience_type, required_playtime } = experienceNeeded;
    const hoursNeeded = Math.ceil(required_playtime / 60);

    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{hoursNeeded}h</b> as {experience_type}
        </Stack.Item>
      </Stack>
    );
  } else if (daysLeft > 0) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{daysLeft}</b> day{daysLeft === 1 ? '' : 's'} left
        </Stack.Item>
      </Stack>
    );
  } else if (data.job_bans && data.job_bans.indexOf(name) !== -1) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>Banned</b>
        </Stack.Item>
      </Stack>
    );
  } else {
    rightSide = (
      <PriorityButtons
        createSetPriority={createSetPriority}
        isOverflow={isOverflow}
        priority={priority}
      />
    );
  }
  return (
    <Box
      className={className}
      style={{
        // PARIAH EDIT
        marginTop: '0',
      }}
    >
      <Stack align="center" /* PARIAH EDIT */>
        <Tooltip
          content={job.description}
          position="right" // PARIAH EDIT bottom-start->right
        >
          <Stack.Item
            className="job-name"
            width="50%"
            style={{
              paddingLeft: '0.3em',
            }}
          >
            {' '}
            {
              // PARIAH EDIT
              !job.alt_titles ? (
                name
              ) : (
                <Dropdown
                  width="100%"
                  options={job.alt_titles}
                  displayText={alt_title_selected}
                  onSelected={(value) =>
                    act('set_job_title', { job: name, new_title: value })
                  }
                />
              )
              // PARIAH EDIT END
            }
          </Stack.Item>
        </Tooltip>

        <Stack.Item width="50%" className="options" /* PARIAH EDIT */>
          {rightSide}
        </Stack.Item>
      </Stack>
    </Box> // PARIAH EDIT
  );
};

const Department: FC<{ children?: ReactNode; department: string }> = (
  props,
) => {
  const { children, department: name } = props;
  const className = `PreferencesMenu__Jobs__departments--${name}`;
  logger.log(name + ': ' + className);

  return (
    <ServerPreferencesFetcher
      render={(data) => {
        if (!data) {
          return null;
        }

        const { departments, jobs } = data.jobs;
        const department = departments[name];

        // This isn't necessarily a bug, it's like this
        // so that you can remove entire departments without
        // having to edit the UI.
        // This is used in events, for instance.
        if (!department) {
          return null;
        }

        const jobsForDepartment = sortJobs(
          Object.entries(jobs).filter(([_, job]) => job.department === name),
          department.head,
        );

        logger.log(className);
        return (
          <Box>
            {
              jobsForDepartment.map(([name, job]) => {
                logger.log(name);
                return (
                  <JobRow /* PARIAH EDIT START - Fixing alt titles */
                    className={classes([
                      className,
                      name === department.head && 'head',
                    ])}
                    key={name}
                    job={job}
                    name={name}
                  />
                );
              }) /* PARIAH EDIT END */
            }

            {children}
          </Box>
        );
      }}
    />
  );
};

// *Please* find a better way to do this, this is RIDICULOUS.
// All I want is for a gap to pretend to be an empty space.
// But in order for everything to align, I also need to add the 0.2em padding.
// But also, we can't be aligned with names that break into multiple lines!
const Gap = (props: { amount: number }) => {
  // 0.2em comes from the paddingBottom in the department listing
  return <Box height={`calc(${props.amount}px + 0.2em)`} />;
};

const JoblessRoleDropdown = (props) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const selected = data.character_preferences.misc.joblessrole;

  const options = [
    {
      displayText: `Join as ${data.overflow_role} if unavailable`,
      value: JoblessRole.BeOverflow,
    },
    {
      displayText: `Join as a random job if unavailable`,
      value: JoblessRole.BeRandomJob,
    },
    {
      displayText: `Return to lobby if unavailable`,
      value: JoblessRole.ReturnToLobby,
    },
  ];

  return (
    <Box position="absolute" right={0} width="30%">
      <Dropdown
        width="100%"
        selected={selected}
        onSelected={createSetPreference(act, 'joblessrole')}
        options={options}
        displayText={
          <Box pr={1}>
            {options.find((option) => option.value === selected)!.displayText}
          </Box>
        }
      />
    </Box>
  );
};

export const JobsPage = () => {
  return (
    <>
      <JoblessRoleDropdown />

      <Stack vertical fill>
        <Gap amount={22} />

        <Stack.Item>
          <Stack fill className="PreferencesMenu__Jobs">
            <Stack.Item mr={1}>
              <Gap amount={36} />

              <PriorityHeaders />

              <Department department="Engineering">
                <Gap amount={6} />
              </Department>

              <Department department="Science">
                <Gap amount={6} />
              </Department>

              <Department department="Silicon">
                <Gap amount={12} />
              </Department>

              <Department department="Assistant" />
            </Stack.Item>

            <Stack.Item mr={1}>
              <PriorityHeaders />

              <Department department="Captain">
                <Gap amount={6} />
              </Department>

              <Department department="Service">
                <Gap amount={6} />
              </Department>

              <Department department="Cargo" />
            </Stack.Item>

            <Stack.Item>
              <Gap amount={36} />

              <PriorityHeaders />

              <Department department="Security">
                <Gap amount={6} />
              </Department>

              <Department department="Medical" />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </>
  );
};
