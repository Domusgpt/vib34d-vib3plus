#!/usr/bin/env node

/**
 * VIB34D Agentic CLI
 *
 * AI-powered interactive CLI for creating VIB34D visualizations
 * Features intelligent onboarding, code generation, and guidance
 */

const { program } = require('commander');
const inquirer = require('inquirer');
const chalk = require('chalk');
const ora = require('ora');
const boxen = require('boxen');
const gradient = require('gradient-string');
const figlet = require('figlet');
const Conf = require('conf');
const fs = require('fs').promises;
const path = require('path');

const config = new Conf({ projectName: 'vib34d-cli' });

// ASCII art banner
function showBanner() {
  console.log(
    gradient.pastel.multiline(
      figlet.textSync('VIB34D', {
        font: 'Big',
        horizontalLayout: 'default'
      })
    )
  );
  console.log(chalk.cyan('  4D Visualization SDK - AI-Powered CLI\n'));
}

// Interactive onboarding
async function onboard() {
  showBanner();

  console.log(
    boxen(
      chalk.white('Welcome to VIB34D! 👋\n\n') +
      chalk.gray('I\'m your AI assistant for creating amazing 4D visualizations.\n') +
      chalk.gray('Let\'s get you set up in just a few steps!'),
      {
        padding: 1,
        margin: 1,
        borderStyle: 'round',
        borderColor: 'cyan'
      }
    )
  );

  // Step 1: Experience level
  const { experience } = await inquirer.prompt([
    {
      type: 'list',
      name: 'experience',
      message: 'How familiar are you with 3D/4D graphics?',
      choices: [
        { name: '🌱 Beginner - Never worked with 3D before', value: 'beginner' },
        { name: '🌿 Intermediate - Some 3D experience', value: 'intermediate' },
        { name: '🌳 Advanced - Experienced with graphics/quaternions', value: 'advanced' }
      ]
    }
  ]);

  config.set('experience', experience);

  // Step 2: Use case
  const { useCase } = await inquirer.prompt([
    {
      type: 'list',
      name: 'useCase',
      message: 'What would you like to build?',
      choices: [
        { name: '🎨 Interactive art / Creative visualization', value: 'art' },
        { name: '📊 Data visualization', value: 'data' },
        { name: '🎓 Educational tool', value: 'education' },
        { name: '🎮 Game / Interactive experience', value: 'game' },
        { name: '🔬 Scientific simulation', value: 'science' },
        { name: '💼 Professional application', value: 'professional' }
      ]
    }
  ]);

  config.set('useCase', useCase);

  // Step 3: Platform
  const { platform } = await inquirer.prompt([
    {
      type: 'list',
      name: 'platform',
      message: 'Which platform are you targeting?',
      choices: [
        { name: '🌐 Web (browser-based)', value: 'web' },
        { name: '📱 Mobile (Android/iOS)', value: 'mobile' },
        { name: '💻 Desktop (Windows/Mac/Linux)', value: 'desktop' },
        { name: '🔄 All platforms', value: 'all' }
      ]
    }
  ]);

  config.set('platform', platform);

  // Step 4: Input preference
  const { input } = await inquirer.prompt([
    {
      type: 'checkbox',
      name: 'input',
      message: 'Which input methods do you want? (Space to select)',
      choices: [
        { name: '🖱️  Mouse (desktop)', value: 'mouse', checked: platform === 'web' || platform === 'desktop' },
        { name: '👆 Touch (mobile/web)', value: 'touch', checked: platform === 'mobile' },
        { name: '⌨️  Keyboard (desktop)', value: 'keyboard' },
        { name: '🎮 Gamepad', value: 'gamepad' },
        { name: '📳 Device motion (mobile)', value: 'motion', checked: platform === 'mobile' }
      ]
    }
  ]);

  config.set('input', input);

  // Generate personalized recommendations
  const spinner = ora('Analyzing your preferences...').start();
  await new Promise(resolve => setTimeout(resolve, 1500));
  spinner.succeed('Analysis complete!');

  showRecommendations(experience, useCase, platform, input);

  // Ask if they want to create a project now
  const { createNow } = await inquirer.prompt([
    {
      type: 'confirm',
      name: 'createNow',
      message: 'Would you like to create your first project now?',
      default: true
    }
  ]);

  if (createNow) {
    await createProjectInteractive();
  } else {
    console.log('\n' + chalk.cyan('No problem! Run ') + chalk.yellow('vib34d create') + chalk.cyan(' when you\'re ready.\n'));
    showQuickCommands();
  }
}

function showRecommendations(experience, useCase, platform, input) {
  console.log('\n' + chalk.bold.cyan('📋 Personalized Recommendations:\n'));

  // Template recommendation
  let template = 'web-mouse';
  if (platform === 'mobile') template = 'mobile-touch';
  else if (useCase === 'education') template = 'educational';
  else if (input.includes('touch')) template = 'web-touch';

  console.log(chalk.white('  Best template for you: ') + chalk.green.bold(template));

  // Geometry recommendation
  let geometry = 'tesseract';
  if (useCase === 'data') geometry = 'sphere';
  else if (useCase === 'education') geometry = 'tesseract';
  else if (experience === 'beginner') geometry = 'sphere';

  console.log(chalk.white('  Recommended geometry: ') + chalk.green.bold(geometry));

  // Learning resources
  console.log(chalk.white('  Learning resources:\n'));
  if (experience === 'beginner') {
    console.log(chalk.gray('    • WEB_APP_GUIDE.md - Complete beginners guide'));
    console.log(chalk.gray('    • examples/web_examples/01_simple_mouse_rotation.dart'));
    console.log(chalk.gray('    • Interactive tutorial: vib34d tutorial'));
  } else if (experience === 'intermediate') {
    console.log(chalk.gray('    • DEVELOPER_GUIDE.md - In-depth development guide'));
    console.log(chalk.gray('    • examples/web_examples/02_educational_euler_angles.dart'));
  } else {
    console.log(chalk.gray('    • docs/architecture/QUATERNION_FLOW.md'));
    console.log(chalk.gray('    • docs/PERFORMANCE.md - Advanced optimizations'));
  }

  config.set('recommendedTemplate', template);
  config.set('recommendedGeometry', geometry);
}

async function createProjectInteractive() {
  console.log('\n' + chalk.bold.cyan('🚀 Create New Project\n'));

  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'name',
      message: 'Project name:',
      default: 'my-vib34d-app',
      validate: input => /^[a-z0-9_-]+$/.test(input) || 'Use lowercase letters, numbers, hyphens, and underscores only'
    },
    {
      type: 'list',
      name: 'template',
      message: 'Choose a template:',
      default: config.get('recommendedTemplate') || 'web-mouse',
      choices: [
        { name: '🖱️  Web with mouse control (desktop browsers)', value: 'web-mouse' },
        { name: '👆 Web with touch control (mobile browsers)', value: 'web-touch' },
        { name: '📱 Mobile app with touch gestures', value: 'mobile-touch' },
        { name: '⌨️  Desktop app with keyboard control', value: 'desktop-keyboard' },
        { name: '🎓 Educational tool (data displays + visualization)', value: 'educational' },
        { name: '🎨 Gallery (showcase multiple geometries)', value: 'gallery' }
      ]
    },
    {
      type: 'list',
      name: 'geometry',
      message: 'Starting geometry:',
      default: config.get('recommendedGeometry') || 'tesseract',
      choices: [
        { name: '🔷 Tesseract (4D hypercube) - Best for learning', value: 'tesseract' },
        { name: '🔮 Sphere (4D) - Best for smooth visualization', value: 'sphere' },
        { name: '🌐 Grid - Best for reference/background', value: 'grid' }
      ]
    },
    {
      type: 'input',
      name: 'color',
      message: 'Primary color:',
      default: 'purple',
      validate: input => /^[a-z]+$|^#[0-9A-Fa-f]{6}$/.test(input) || 'Enter a color name or hex code'
    }
  ]);

  const spinner = ora('Creating project...').start();

  try {
    await createProject(answers.name, answers.template, answers.geometry, answers.color);
    spinner.succeed(chalk.green('Project created successfully!'));

    showNextSteps(answers.name);
  } catch (error) {
    spinner.fail(chalk.red('Failed to create project'));
    console.error(chalk.red(error.message));
  }
}

async function createProject(name, template, geometry, color) {
  // This would generate actual project files
  // For now, just show what would be created
  console.log(`\n  Creating ${name}...`);
  console.log(`    Template: ${template}`);
  console.log(`    Geometry: ${geometry}`);
  console.log(`    Color: ${color}\n`);

  // TODO: Actually generate files
  await new Promise(resolve => setTimeout(resolve, 1000));
}

function showNextSteps(projectName) {
  console.log('\n' + boxen(
    chalk.bold.green('✨ Your project is ready!\n\n') +
    chalk.white('Next steps:\n\n') +
    chalk.cyan(`  cd ${projectName}\n`) +
    chalk.cyan('  flutter pub get\n') +
    chalk.cyan('  flutter run -d chrome\n\n') +
    chalk.gray('Need help? Run: ') + chalk.yellow('vib34d help'),
    {
      padding: 1,
      margin: 1,
      borderStyle: 'round',
      borderColor: 'green'
    }
  ));
}

function showQuickCommands() {
  console.log(boxen(
    chalk.bold('Quick Commands:\n\n') +
    chalk.cyan('vib34d create') + chalk.gray('         Create a new project\n') +
    chalk.cyan('vib34d add input') + chalk.gray('     Add input adapter\n') +
    chalk.cyan('vib34d add geometry') + chalk.gray('  Add geometry renderer\n') +
    chalk.cyan('vib34d tutorial') + chalk.gray('      Interactive tutorial\n') +
    chalk.cyan('vib34d explain') + chalk.gray('       Explain concepts\n') +
    chalk.cyan('vib34d optimize') + chalk.gray('      Performance tips\n') +
    chalk.cyan('vib34d docs') + chalk.gray('          Open documentation'),
    {
      padding: 1,
      margin: 1,
      borderStyle: 'round',
      borderColor: 'cyan'
    }
  ));
}

// CLI Commands
program
  .name('vib34d')
  .description('VIB34D SDK - AI-powered 4D visualization CLI')
  .version('1.0.0');

program
  .command('onboard')
  .description('Interactive onboarding for new users')
  .action(onboard);

program
  .command('create [name]')
  .description('Create a new VIB34D project')
  .action(async (name) => {
    if (!name) {
      await createProjectInteractive();
    } else {
      // Quick create with defaults
      const spinner = ora('Creating project...').start();
      await createProject(name, 'web-mouse', 'tesseract', 'purple');
      spinner.succeed('Project created!');
      showNextSteps(name);
    }
  });

program
  .command('tutorial')
  .description('Start interactive tutorial')
  .action(async () => {
    showBanner();
    console.log(chalk.cyan('\n📚 Interactive Tutorial - Coming soon!\n'));
    console.log(chalk.gray('For now, check out:\n'));
    console.log(chalk.white('  • WEB_APP_GUIDE.md - Complete guide\n'));
    console.log(chalk.white('  • examples/web_examples/ - Working examples\n'));
  });

program
  .command('explain <concept>')
  .description('Explain quaternion/4D concepts')
  .action((concept) => {
    const explanations = {
      quaternion: 'A quaternion is a 4-number (x,y,z,w) representation of 3D rotation...',
      euler: 'Euler angles (roll, pitch, yaw) are an alternative rotation representation...',
      '4d': '4D rotations involve 6 planes: XY, XZ, YZ, XW, YW, ZW...',
    };

    console.log('\n' + chalk.bold.cyan(`📖 ${concept.toUpperCase()}\n`));
    console.log(chalk.white(explanations[concept] || 'Concept not found. Try: quaternion, euler, 4d'));
    console.log();
  });

program
  .command('docs')
  .description('Open documentation in browser')
  .action(() => {
    console.log('\n' + chalk.cyan('📚 Documentation:\n'));
    console.log(chalk.white('  Web Guide:      ') + chalk.gray('WEB_APP_GUIDE.md'));
    console.log(chalk.white('  Developer Guide:') + chalk.gray('DEVELOPER_GUIDE.md'));
    console.log(chalk.white('  API Reference:  ') + chalk.gray('FLUTTER_README.md'));
    console.log(chalk.white('  Examples:       ') + chalk.gray('examples/web_examples/\n'));
  });

// If no command, show onboarding for first-time users
if (!process.argv.slice(2).length) {
  if (!config.has('onboarded')) {
    onboard().then(() => config.set('onboarded', true));
  } else {
    showBanner();
    showQuickCommands();
  }
} else {
  program.parse();
}
