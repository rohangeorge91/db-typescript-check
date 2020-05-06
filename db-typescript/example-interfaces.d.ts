/**
 * Again, I just went with the documentation on TypeScript and tried to learn about it as much as possible.
 * there are still holes in my knowledge. So I am using the 'type' keyword to define the various types possible
 * 
 * The docs are bit vage on differnce of type and interface.
 * https://www.typescriptlang.org/docs/handbook/advanced-types.html#interfaces-vs-type-aliases
 * and the below says otherwise... so I am lost.
 * https://medium.com/@martin_hotell/interface-vs-type-alias-in-typescript-2-7-2a8f1777af4c
 * 
 */

// The type are simple an identical to the table structure
type Size = {
	id: string;
	value: number;
}

type Color = {
	id: string;
} 

type ContainerType = {
	id: string;
}

// optional used if you want to get nested objects <- again avoid for quicker operation on the db.
type ContainerTypeColorMap = {
	id: number;
	containerType: ContainerType;
	color?: Color;
	colorId: string;
}

type Container = {
	id: number;
	type?: ContainerType;
	typeId: string;
	size?: Size;
	sizeId: string;
}

type Bauble = {
	id: number;
	containerId: number;
	container?: Container;
	colorId: string;
	color?: Color;
	sizeId: string;
	size?: Size;
}

// This type is to have a handler for all object which can work with the database IO.
type DataObject = Size | Color | ContainerType | ContainerTypeColorMap | Container | Bauble;

/**
 * The below Data operation interface provide a basic CRUD operation for the type. The implmentation needs to write code for the database operation.
 */
interface IDataOperation<DataObject> {
	create(obj: DataObject): Promise<DataObject>;
	read(id?: number | string): Promise<DataObject> | Promise<DataObject[]>;
	update(obj: DataObject): Promise<DataObject>;
	delete(obj: DataObject): Promise<boolean>;
}

/**
 * Implements an ORM for the given DataObject using Sequelize and promise return the output for the respective operation for the given DataObject type.
 */
export class DataOperation<T> implements IDataOperation<T> {
	// TODO: in the implmentation this will generate an orm mapper to the library.
	dbMapper(obj: T): void;
	// based on the Request find out the operation get -> read, create -> post, update -> put, delete -> delete
	operation(request: Request, response: Response): void;
	create(obj: T): Promise<T>;
	read(id?: string | number): Promise<T> | Promise<T[]>;
	update(obj: T): Promise<T>;
	delete(obj: T): Promise<boolean>;
}

/**
 * The below Dictionary is used to make a map where the key is the name of the DataObject which is extracted from the path param and then the respective operation
 * is called.
 */
interface DictionaryDataOperationMapper {
	[index: string]: DataOperation<DataObject>;
}

/*
	So by API's I assure you are referening to endpoint point which can be communicated to get some data or to process some data.
	Since I cant define it here, my plan of attack is to make a express route .all where we get the body, method and based on the 
	method we call the create, read, update or delete implementation respectively. so the path /:objectType will basically map to
	a dictionary with the class implmentation of each DataObject type.
*/