# MCPanel CLI v3.0

What should be implemented:
- same CLI framework:
    - lazy-load modules and configuration (if exists);
    - resolve input options

Something i've had in mind:

`mcpanel.js`:
```typescript
const args: Array<any>

let module: string = args[1]
let action: string = args[2]

mcpanel.dispatch(module, action, args.splice(3))
```

sample `module.js`:
```typescript
const actions = {
    'something': (args: any): void => {
        // do something
    }
}
export default function (action, args) {
    // call action from object
}
```
