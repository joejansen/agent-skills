---
name: requirements-interview
description: Deep requirements gathering through structured interviews. Use when the user asks to "interview me", "gather requirements", "help me think through", "spec out", "write a spec", or needs comprehensive understanding before implementation. Triggers on phrases like "ask me questions about the project", "help me plan", or "let's define requirements".
version: 1.0.0
---

# Requirements Interview Skill

Conduct thorough, in-depth interviews to gather comprehensive requirements before implementation. This skill uses the AskUserQuestion tool to systematically explore all aspects of a project.

## Interview Process

### Phase 1: Project Foundation

Start by understanding the core vision:

- What problem is being solved?
- Who are the users/stakeholders?
- What does success look like?
- What are the non-negotiables vs nice-to-haves?

### Phase 2: Technical Deep-Dive

Explore implementation details:

- Architecture and system design decisions
- Data models and state management
- API contracts and integration points
- Performance requirements and constraints
- Security considerations and threat models
- Scalability expectations

### Phase 3: User Experience & Interface

Understand the human side:

- User flows and journeys
- Edge cases in user interaction
- Error states and recovery paths
- Accessibility requirements
- Device/platform considerations
- Loading states and perceived performance

### Phase 4: Concerns & Risks

Surface potential issues:

- What could go wrong?
- What are you most worried about?
- What's been tried before that didn't work?
- What constraints exist (time, budget, tech stack)?
- What dependencies or blockers exist?

### Phase 5: Tradeoffs & Priorities

Make explicit decisions:

- Speed vs quality tradeoffs
- Build vs buy decisions
- Simplicity vs flexibility
- MVP scope vs full vision
- Technical debt tolerance

## Interview Guidelines

**Ask non-obvious questions.** Don't ask "What features do you want?" Instead ask:

- "What's the most annoying thing about current solutions?"
- "If this fails, what's the most likely reason?"
- "What would make you delete this app after a week?"
- "Which user would get the MOST value, and which would get the LEAST?"
- "What's the smallest version of this that would still be useful?"
- "What happens when the network goes down mid-operation?"
- "How will you know if this is successful in 6 months?"

**Dig deeper when useful.** When the user answers:

- Ask "Why?" if the answer seems wrong or shallow
- Ask for specific examples
- Ask about exceptions and edge cases
- Challenge assumptions respectfully
- Explore the implications of their answers

**Cover blind spots.** Proactively ask about things users often forget:

- Offline/degraded mode behavior
- Data migration from existing systems
- Internationalization/localization
- Audit logging and compliance
- Backup and disaster recovery
- Admin/operator experience (not just end users)
- Onboarding and first-run experience
- Sunset and data deletion

**Use the AskUserQuestion tool effectively:**

- Ask 1-4 focused questions per turn
- Provide options when helpful, but always allow "Other"
- Group related questions together
- Adapt based on previous answers

## Spec Output Format

After the interview is complete, write a comprehensive spec to a file or plan document.

## Execution Instructions

1. **Begin the interview** by introducing what you'll cover and asking about the project at a high level
2. **Use AskUserQuestion tool** for each round of questions - ask 2-4 questions per turn
3. **Adapt your questions** based on answers - don't follow a rigid script
4. **Go deep before going wide** - fully explore one area before moving to the next
5. **Continue until complete** - don't stop early, cover all phases
6. **Summarize periodically** - reflect back what you've learned to validate understanding
7. **Ask if there's more** - before writing the spec, ask if there's anything else they want to add
8. **Write the spec** - create a file with the comprehensive specification
9. **Review with user** - offer to clarify or expand any section
